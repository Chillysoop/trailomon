local model=require "simulation.expedition"
local aims=require "simulation.journal_aims"
local progression=require "simulation.progression"
local save=require "services.save"
local util=require "simulation.util"
return function(test,command,valid,equal)
    local function depart(p,partner)
        if partner then command(p,"crew",{species="loamling"});command(p,"crew",{species=partner}) end
        command(p,"depart")
    end
    local function arrive(p,path,late)
        local s=p.run;s.mode="landmark";s.target=5;s.progress=s.distance;s.day=late and 27 or 20
        s.pending=nil;s.battle=nil;s.encounter=nil;s.return_rng=nil
        command(p,"leave",{branch=path});s.progress=s.distance-1;s.food=90
        command(p,"step");assert(s.mode=="result" and s.outcome==(late and "late" or "delivered"))
    end
    local function fight(p,legacy)
        assert(model.debug(p,"event","scavengers"));command(p,"choice",{id="battle"})
        if legacy then
            p.run.pending=nil;assert(require("simulation.combat_manual").start(p.run,"scavengers",{1,2}))
            command(p,"round",{actions={{member=1,kind="pressure"},{member=2,kind="guard"}}})
        else command(p,"battle_start",{team={1,2}});command(p,"battle_step") end
    end
    test("journal aims require two distinct delivered departure pairs",function()
        local p=model.new(1848);depart(p);local pair=p.run.aim_journey.pair
        assert(pair=="brindlehorn+loamling");arrive(p,"ridge")
        assert(p.profile.aims.pairs[pair]==1 and not p.profile.aims.completed.company)
        command(p,"new");p.run.crew={p.run.crew[2],p.run.crew[1]};p.run.crew[1].name="A new name"
        depart(p);assert(p.run.aim_journey.pair==pair);arrive(p,"ridge")
        assert(not p.profile.aims.completed.company)
        command(p,"new");depart(p,"bellmoth");arrive(p,"gorge",true)
        assert(not p.profile.aims.pairs["bellmoth+brindlehorn"])
        command(p,"new");depart(p,"bellmoth");arrive(p,"gorge")
        assert(p.profile.aims.completed.company==4)
        assert(p.run.log[#p.run.log].text=="Journal aim completed: Fresh company.")
    end)
    test("solo travel and roadside recruits do not invent departure pairs",function()
        local p=model.new(1848);command(p,"crew",{species="loamling"});depart(p)
        assert(not p.run.aim_journey.pair);p.run.crew[2]=progression.companion("loamling");arrive(p,"ridge")
        assert(next(p.profile.aims.pairs)==nil)
        command(p,"new");depart(p);local pair=p.run.aim_journey.pair
        p.run.crew[3]=progression.companion("cindercoil");arrive(p,"gorge")
        assert(p.profile.aims.pairs[pair]==2 and not p.profile.aims.completed.company)
    end)
    test("both paths count arrivals, including late, but never early returns",function()
        local p=model.new(5);depart(p);p.run.branches.last="gorge";command(p,"return")
        assert(next(p.profile.aims.paths)==nil and not p.profile.aims.completed.peaceful)
        command(p,"new");depart(p);arrive(p,"ridge",true)
        assert(p.profile.aims.paths.ridge==2 and p.profile.aims.completed.peaceful==2)
        command(p,"new");depart(p);arrive(p,"gorge")
        assert(p.profile.aims.completed.paths==3)
    end)
    test("peaceful aim allows previews and pre-exchange withdrawal only",function()
        local p=model.new(9);depart(p);assert(model.debug(p,"event","scavengers"))
        command(p,"choice",{id="battle"});command(p,"battle_start",{team={1,2}});command(p,"battle_back")
        assert(not p.run.aim_journey.fought)
        command(p,"choice",{id="battle"});command(p,"withdraw");arrive(p,"ridge")
        assert(p.profile.aims.completed.peaceful==1)
        for _,legacy in ipairs({false,true}) do
            p=model.new(9);depart(p);fight(p,legacy);assert(p.run.aim_journey.fought)
            command(p,"withdraw");arrive(p,"ridge");assert(not p.profile.aims.completed.peaceful)
            command(p,"new");depart(p);assert(not p.run.aim_journey.fought);arrive(p,"gorge")
            assert(p.profile.aims.completed.peaceful==2)
        end
    end)
    test("aim checkpoints replay exactly and completions are idempotent",function()
        local p=model.new(11);depart(p);fight(p);command(p,"withdraw")
        local copy=util.copy(p);arrive(p,"ridge");arrive(copy,"ridge");equal(p,copy)
        assert(not p.profile.aims.completed.peaceful)
        command(p,"new");depart(p,"bellmoth");copy=util.copy(p)
        arrive(p,"gorge");arrive(copy,"gorge");equal(p,copy)
        local before=util.copy(p);assert(not model.finish(p,"delivered","Duplicate"));assert(not progression.commit(p.profile,p.run));equal(p,before)
        local notes=0;for _,entry in ipairs(p.run.log) do if entry.text:find("Journal aim completed:",1,true) then notes=notes+1 end end
        assert(notes==3)
        local completed=util.copy(p.profile.aims.completed)
        for _=1,12 do command(p,"new");depart(p);command(p,"return") end
        equal(p.profile.aims.completed,completed);assert(#p.profile.history==10)
    end)
    test("old saves recover only supported history and start new tracking at departure",function()
        local p=model.new(7);depart(p);p.run.aim_journey=nil;p.profile.aims=nil
        assert(aims.rows(p)[1].note:find("older save",1,true))
        valid(p);arrive(p,"ridge");assert(not p.profile.aims.completed.peaceful and next(p.profile.aims.pairs)==nil)
        command(p,"new");depart(p);p.run.aim_journey=nil;arrive(p,"gorge")
        p.profile.aims=nil;valid(p);local before=util.copy(p)
        local a=aims.records(p.profile);assert(a.completed.paths==2 and not a.completed.peaceful);equal(p,before)
        command(p,"new");depart(p);arrive(p,"ridge")
        assert(p.profile.aims.completed.paths==2 and p.profile.aims.completed.peaceful==3)
    end)
    test("reading aims is pure and completion has no resource or random rewards",function()
        local p=model.new(4);local before=util.copy(p)
        for _=1,20 do assert(#aims.rows(p)==3) end;equal(p,before)
        depart(p);local rng=util.copy(p.run.rng);local resources={}
        for _,key in ipairs({"food","coins","repairs","medicine","wagon","cargo","traveler","day"}) do resources[key]=p.run[key] end
        p.run.branches.last="ridge";assert(model.finish(p,"delivered","Fixture arrival"));valid(p)
        for key,value in pairs(resources) do assert(p.run[key]==value) end;equal(p.run.rng,rng)
        local rows=aims.rows(p);assert(rows[3].done and rows[1].status=="1 / 2 pairs")
    end)
    test("malformed goal records are rejected without breaking older snapshots",function()
        local p=model.new(1848);depart(p);arrive(p,"ridge");valid(p)
        local mutations={
            function(q) q.profile.aims.pairs["loamling+brindlehorn"]=1 end,
            function(q) q.profile.aims.paths.ocean=1 end,
            function(q) q.profile.aims.completed.company=1 end,
            function(q) q.profile.aims.completed.peaceful=99 end,
            function(q) q.run.aim_journey.fought="false" end,
            function(q) q.run.aim_journey.pair="brindlehorn+brindlehorn" end,
        }
        for _,mutate in ipairs(mutations) do local q=util.copy(p);mutate(q);assert(not save.validate(q)) end
        p.profile.aims=nil;p.run.aim_journey=nil;valid(p)
    end)
end
