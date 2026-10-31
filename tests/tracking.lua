local model=require "simulation.expedition"
local tracking=require "simulation.tracking"
local discovery=require "simulation.discovery"
local guide=require "simulation.field_guide"
local util=require "simulation.util"
local progression=require "simulation.progression"
return function(test,command,valid,equal)
    local function at_landmark(starter)
        local p=model.new(1848,"discovery");command(p,"starter",{species=starter});command(p,"depart")
        local s=p.run;s.target=starter=="brindlehorn" and 4 or 2;s.progress=s.distance;s.mode="landmark"
        s.terrain=s.target==4 and "marsh" or "meadow";s.seen.courier_intro=true;s.seen.discover_loamling=true
        return p
    end
    test("both starting haulers have optional invitations with exact food and retention",function()
        for _,starter in ipairs({"brindlehorn","reedskipper"}) do
            local p=at_landmark(starter);local id=starter=="brindlehorn" and "reedskipper" or "brindlehorn"
            local before=util.copy(p);assert(discovery.invitation(p)==id);equal(p,before)
            command(p,"meet_wild");local saved=util.copy(p);local choice=model.events.by_id[p.run.pending.id].choices[1]
            local preview=model.events.recruit_preview(p.run,choice);local day=p.run.day
            command(p,"choice",{id="invite"});command(saved,"choice",{id="invite"});equal(p,saved)
            assert(p.run.day==day and p.run.food==preview.food_after and model.resources.daily_food(p.run)==preview.meals_after)
            assert(#p.run.crew==2 and not discovery.invitation(p));command(p,"return");command(p,"new")
            assert(p.profile.roster[id]);valid(p)
        end
        local p=model.new(3);command(p,"depart");p.run.mode="landmark";p.run.progress=p.run.distance
        assert(not discovery.invitation(p));assert(not model.command(p,"meet_wild"))
    end)
    test("hauler invitation cannot bypass a full crew or food and always permits passing",function()
        local p=at_landmark("brindlehorn");p.run.crew[2]=progression.companion("loamling");p.run.crew[3]=progression.companion("bellmoth")
        command(p,"meet_wild");local before=util.copy(p);assert(not model.command(p,"choice",{id="invite"}));equal(p,before)
        command(p,"choice",{id="pass"});assert(not discovery.invitation(p))
        p=at_landmark("reedskipper");p.run.food=3;command(p,"meet_wild");before=util.copy(p)
        assert(not model.command(p,"choice",{id="invite"}));equal(p,before);command(p,"choice",{id="pass"});assert(p.run.food==3)
    end)
    test("guide clues distinguish reports from sightings without changing saved knowledge",function()
        local p=model.new(14);local before=util.copy(p);local rows=guide.rows(p)
        for _,r in ipairs(rows) do assert(r.clue.place~="" and r.clue.method~="" and r.evidence=="Report / unconfirmed") end
        equal(p,before);guide.observe(p.run,"brindlehorn");assert(guide.rows(p)[1].evidence=="Seen firsthand")
    end)
    test("track plan is saved before the choice and inspection or other RNG cannot reroll it",function()
        local p=model.new(11);command(p,"depart");local before=util.copy(p)
        for _=1,20 do assert(tracking.preview(p).available);guide.rows(p) end;equal(p,before)
        local record=util.copy(p.run.tracks['2']);command(p,"rest");equal(p.run.tracks['2'],record)
        require("simulation.rng").next(p.run.rng,"events");equal(p.run.tracks['2'],record)
        local q=util.copy(p);local food,day=p.run.food,p.run.day;local meals=tracking.preview(p).meals
        command(p,"follow_tracks");command(q,"follow_tracks");equal(p,q)
        assert(p.run.day==day+1 and p.run.food==food-meals and p.run.tracks['2'].used)
        if p.run.mode=="event" then command(p,"choice",{id=model.events.by_id[p.run.pending.id].choices[#model.events.by_id[p.run.pending.id].choices].id}) end
        if p.run.road_story then command(p,"ack_story") end
        before=util.copy(p);assert(not model.command(p,"follow_tracks"));equal(p,before)
    end)
    test("empty tracks and encounter tracks both resolve once with truthful costs",function()
        local outcomes,found_species={},{}
        for seed=1,24 do
            local p=model.new(seed);command(p,"depart");local r=p.run.tracks['2'];outcomes[r.empty and "empty" or "found"]=true
            found_species[r.species]=true
            local event=r.event;command(p,"follow_tracks")
            if r.empty then assert(p.run.mode=="stopped" and p.run.road_story and not p.run.pending)
            else assert(p.run.mode=="event" and p.run.pending.id==event) end
            valid(p)
        end
        assert(outcomes.empty and outcomes.found)
        assert(found_species.brindlehorn and found_species.loamling,"Consecutive journey seeds need different clues")
    end)
    test("search guards preserve snapshots for closure hunger old saves and resolved clues",function()
        local p=model.new(7);command(p,"depart")
        local variants={function(s) s.day=31 end,function(s) s.food=0 end,function(s) s.tracks=nil end,function(s) s.seen[s.tracks['2'].event]=true end,function(s) s.road_story="Read first" end}
        for _,change in ipairs(variants) do local q=util.copy(p);change(q.run);local before=util.copy(q)
            assert(not tracking.preview(q).available and not model.command(q,"follow_tracks"));equal(q,before);valid(q)
        end
        p.run.tracks=nil;command(p,"return");command(p,"new");command(p,"depart");assert(tracking.preview(p).available)
        local bad=util.copy(p);bad.run.tracks['2'].event="courier_intro";assert(not require("services.save").validate(bad))
        bad=util.copy(p);bad.run.tracks['2'].roll=math.huge;assert(not require("services.save").validate(bad))
        bad=util.copy(p);bad.run.tracks['2']={roll=0.5,empty=false,used=false};assert(not require("services.save").validate(bad))
    end)
    test("route entry stores a new habitat clue and search death cannot grant an encounter",function()
        local p=model.new(19);command(p,"depart");p.run.mode="landmark";p.run.progress=p.run.distance
        command(p,"leave",{branch="woodland"});local r=p.run.tracks['3'];assert(r and (r.species=="bellmoth" or r.species=="loamling" or r.species=="cindercoil"))
        p.run.mode="stopped";p.run.day=20;p.run.traveler=0.1
        -- Pin a cold day using the existing weather stream, without touching the clue.
        for n=1,100 do p.run.rng.weather=100000+n*1000;local q=util.copy(p);model.command(q,"follow_tracks");if q.run.mode=="result" then
            command(p,"follow_tracks");assert(not p.run.pending and p.run.outcome=="rescued");return
        end end
        error("No cold-day terminal fixture found")
    end)
    test("searching every new stretch still produces bounded repeatable expeditions",function()
        local policy=require "tools.report.policy"
        local function play(seed,starter)
            local p=model.new(seed,"discovery");command(p,"starter",{species=starter})
            local steps=0
            while p.run.mode~="result" and steps<350 do
                local action
                if tracking.preview(p).available then action={command="follow_tracks"}
                elseif discovery.invitation(p) then action={command="meet_wild"}
                else local id,args=policy.next(p,"careful");action={command=id,args=args} end
                assert(action,"Policy stalled")
                command(p,action.command,action.args);steps=steps+1
            end
            assert(p.run.mode=="result","Searching stalled");return p
        end
        for _,starter in ipairs({"brindlehorn","reedskipper"}) do for seed=1,12 do equal(play(seed,starter),play(seed,starter)) end end
    end)
end
