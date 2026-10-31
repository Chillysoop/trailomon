package.path="./?.lua;./?/init.lua;"..package.path
local model=require "simulation.expedition"
local save=require "services.save"
local util=require "simulation.util"
local progression=require "simulation.progression"
local passed=0
local function assert_equal(a,b,why)
    if type(a)~=type(b) then error((why or "").." type differs") end
    if type(a)=="table" then
        for k,v in pairs(a) do assert_equal(v,b[k],tostring(k)) end
        for k in pairs(b) do assert(a[k]~=nil,"Extra key "..tostring(k)) end
    else assert(a==b,(why or "")..": "..tostring(a).." != "..tostring(b)) end
end
local function valid(p) local ok,why=save.validate(p); assert(ok,why) end
local function command(p,id,args)
    local ok,why=model.command(p,id,args); assert(ok,id..": "..tostring(why)); valid(p)
end
local function test(name,fn)
    local ok,why=pcall(fn)
    if not ok then io.stderr:write("FAIL "..name..": "..tostring(why).."\n"); os.exit(1) end
    passed=passed+1; print("PASS "..name)
end
local function depart(seed)
    local p=model.new(seed);command(p,"depart");return p
end
local function act(p,strategy)
    local s=p.run
    if s.mode=="preparation" then command(p,"depart")
    elseif s.mode=="stopped" or s.mode=="traveling" then
        if s.food<model.resources.daily_food(s)*3 and model.forage_preview(s).net>0 then command(p,"forage")
        elseif s.wagon<28 and s.repairs>0 then command(p,"repair")
        elseif not model.resources.hauler(s) or s.crew[s.hauler].stamina<18 then command(p,"rest")
        elseif s.mode=="stopped" then command(p,"resume")
        else command(p,"step") end
    elseif s.mode=="landmark" then
        if s.target==4 and not s.flags.river_inspected then command(p,"river",{method="inspect"})
        elseif s.target==4 and not s.flags.river_crossed then command(p,"river",{method=s.coins>=12 and "ferry" or "rope"})
        elseif s.target==3 and s.food<55 and s.coins>=6 and model.resources.weight(s)+10<=model.resources.capacity(s) then command(p,"buy",{item="food"})
        else command(p,"leave",{branch=s.target==2 and (strategy=="careful" and "meadow" or "woodland") or "ridge"}) end
    elseif s.mode=="event" then
        local event=model.events.by_id[s.pending.id]
        local pick
        for _,c in ipairs(event.choices) do
            if model.events.available(s,c,p.profile) and (strategy~="peaceful" or not c.battle) then pick=c;break end
        end
        if strategy=="fighter" then
            for _,c in ipairs(event.choices) do if c.battle and model.events.available(s,c,p.profile) then pick=c;break end end
        end
        assert(pick,"No valid event choice")
        command(p,"choice",{id=pick.id})
    elseif s.mode=="combat_select" then
        local team={};for i,c in ipairs(s.crew) do if #team<2 and model.resources.ready(c,4) then team[#team+1]=i end end
        if #team>0 then command(p,"battle_start",{team=team}) else command(p,"withdraw") end
    elseif s.mode=="combat" then
        command(p,"battle_step")
    elseif s.mode=="combat_result" then command(p,"battle_continue")
    end
end
local function journey(seed,strategy,checkpoint,legacy)
    local p=model.new(seed)
    if legacy then p.run.combat_effort=nil end
    for i=1,250 do
        if p.run.mode=="result" then return p end
        act(p,strategy)
        if checkpoint and i%checkpoint==0 then p=util.copy(p); valid(p) end
    end
    error("Journey never ended")
end

test("initial snapshot and content budgets",function()
    local p=model.new(1848);valid(p)
    assert(#model.events.defs==18 and #model.route==6 and #model.species.order==6)
end)
test("new journeys do not share mutable state",function()
    local a,b=model.new(9),model.new(9)
    a.run.crew[1].stamina=0;a.run.log[1].text="changed"
    assert(b.run.crew[1].stamina==100 and b.run.log[1].text~="changed")
    assert(a.profile.roster.brindlehorn.stamina==100)
end)
test("unavailable commands leave the entire snapshot unchanged",function()
    local p=model.new(10);local before=util.copy(p)
    assert(not model.command(p,"step"));assert_equal(p,before)
    assert(not model.command(p,"buy",{item="bad"}));assert_equal(p,before)
    p.run.coins=0;before=util.copy(p)
    assert(not model.command(p,"buy",{item="medicine"}));assert_equal(p,before)
end)
test("departure requires a draft companion and respects capacity",function()
    local p=model.new(1)
    command(p,"crew",{species="brindlehorn"});command(p,"crew",{species="bellmoth"})
    assert(not model.command(p,"depart"))
    p.run.food=119;local before=util.copy(p)
    assert(not model.command(p,"buy",{item="food"}));assert_equal(before,p)
end)
test("forage consumes a day and food and depletes a site",function()
    local p=depart(1848);p.run.food=25
    local food,day=p.run.food,p.run.day
    local preview=model.forage_preview(p.run)
    command(p,"forage")
    assert(p.run.day==day+1 and p.run.food==food+preview.net)
    assert(model.forage_preview(p.run).gross<preview.gross)
end)
test("forage preview matches capacity limits and the food actually available",function()
    for _,case in ipairs({{wagon="covered",food=90,packed=4,net=1},{wagon="standard",food=119,packed=3,net=0},{wagon="standard",food=1,packed=18,net=17}}) do
        local p=model.new(1848);p.profile.covered=true
        command(p,"wagon",{id=case.wagon});command(p,"depart")
        p.run.food=case.food;valid(p)
        local preview=model.forage_preview(p.run)
        assert(preview.packed==case.packed and preview.net==case.net)
        command(p,"forage")
        assert(p.run.food==case.food+preview.net)
        assert(model.resources.weight(p.run)<=model.resources.capacity(p.run))
    end
end)
test("legacy manual saves retain action validation and once-only assists",function()
    local p=depart(3);assert(model.debug(p,"event","scavengers"));command(p,"choice",{id="battle"})
    command(p,"battle_start",{team={1,2}})
    p.run.pending=nil;p.run.return_rng=nil;assert(require("simulation.combat_manual").start(p.run,"scavengers",{1,2}));valid(p)
    local before=util.copy(p)
    assert(not model.command(p,"round",{actions={{member=1,kind="pressure"},{member=1,kind="guard"}}}));assert_equal(p,before)
    command(p,"round",{actions={{member=1,kind="assist"},{member=2,kind="guard"}}})
    before=util.copy(p)
    assert(not model.command(p,"round",{actions={{member=1,kind="assist"},{member=2,kind="guard"}}}));assert_equal(p,before)
end)
test("recruitment, river and battle survive a checkpoint",function()
    local p=depart(13)
    assert(model.debug(p,"event","cinder_shelter"));command(p,"choice",{id="help"})
    assert(model.debug(p,"event","cinder_return"));command(p,"choice",{id="invite"})
    assert(#p.run.crew==3)
    assert(model.debug(p,"event","territorial"));command(p,"choice",{id="battle"});command(p,"battle_start",{team={1,3}})
    local copy=util.copy(p);valid(copy)
    while p.run.mode=="combat" do
        command(p,"battle_step");command(copy,"battle_step")
    end
    assert_equal(p,copy)
    command(p,"battle_continue")
    p.run.mode="landmark";p.run.target=4;p.run.progress=p.run.distance
    command(p,"river",{method="inspect"});command(p,"river",{method="ferry"})
    command(p,"return")
    assert(p.profile.roster.cindercoil and p.profile.covered)
    assert(not progression.commit(p.profile,p.run));assert(#p.profile.history==1)
    command(p,"new",{seed=14});assert(p.run.food==90 and p.run.crew[1].condition==100)
end)
test("pending event cannot reroll through save and reload",function()
    local p=depart(88);assert(model.debug(p,"event","shortcut"));valid(p)
    local copy=util.copy(p)
    command(p,"choice",{id="risk"});command(copy,"choice",{id="risk"});assert_equal(p,copy)
end)
test("bad saves are rejected without throwing",function()
    for _,value in ipairs({false,9,"bad",{}, {schema=999}}) do assert(not save.validate(value)) end
    local p=model.new(4);p.run.rng.events=0;assert(not save.validate(p))
    p=model.new(4);p.run.food=0/0;assert(not save.validate(p))
    p=model.new(4);p.run.mode="event";assert(not save.validate(p))
end)
test("presentation speed and pause never change simulation results",function()
    local clock=require "services.travel_clock"
    local function driven(seconds)
        local p,c=depart(5),clock.new()
        for frame=1,20000 do
            if p.run.mode=="result" then return p end
            if p.run.mode=="traveling" then
                if clock.tick(c,0.1,true,seconds) then act(p,"careful") end
            else clock.tick(c,0.1,false,seconds);act(p,"careful") end
        end
        error("Clock-driven journey did not finish")
    end
    assert_equal(driven(20),driven(2.5))
    local ca=clock.new()
    ca.elapsed=19.9;assert(not clock.tick(ca,0.1,false,20));assert(ca.elapsed==0)
    assert(not clock.tick(ca,999,true,20));assert(ca.elapsed<=0.25)
end)
test("rescue, voluntary return and result immutability",function()
    local p=depart(4);p.run.traveler=1;p.run.food=0;command(p,"rest");assert(p.run.outcome=="rescued")
    local before=util.copy(p);assert(not model.command(p,"rest"));assert_equal(p,before)
    p=depart(4);command(p,"return");assert(p.run.outcome=="returned")
    p=depart(4);p.run.day=31;command(p,"rest");assert(p.run.outcome=="rescued")
end)
test("seeded journeys match uninterrupted and checkpointed execution",function()
    for _,seed in ipairs({1,7,13,42,1848,2026,6011}) do
        assert_equal(journey(seed,"careful"),journey(seed,"careful",3))
    end
end)
test("reference strategies finish without negative resources or deadlocks",function()
    local counts={}
    for _,strategy in ipairs({"careful","peaceful"}) do
        for seed=1,40 do
            local p=journey(seed,strategy)
            counts[p.run.outcome]=(counts[p.run.outcome] or 0)+1
            valid(p)
        end
    end
    assert((counts.delivered or 0)>0,"No on-time deliveries")
    for key,value in pairs(counts) do print("  "..key..": "..value) end
end)

test("a fighting strategy completes full expeditions and checkpointed replays",function()
    local outcomes={};local encounters=0
    for seed=1,40 do
        local p=journey(seed,"fighter")
        assert_equal(p,journey(seed,"fighter",2));valid(p)
        outcomes[p.run.outcome]=(outcomes[p.run.outcome] or 0)+1
        for _,entry in ipairs(p.run.log) do if entry.text:find("Exchange ",1,true) then encounters=encounters+1 end end
    end
    assert(encounters>0 and (outcomes.delivered or 0)>0)
    for key,n in pairs(outcomes) do print("  fighting "..key..": "..n) end
    print("  fighting exchange journal entries: "..encounters)
end)
test("river alternatives and both route branches remain available",function()
    for _,method in ipairs({"ferry","rope","anchor","swim"}) do
        local p=depart(23)
        if method=="swim" then p.run.crew[1]=progression.companion("reedskipper") end
        p.run.mode="landmark";p.run.target=4;p.run.progress=p.run.distance
        command(p,"river",{method="inspect"});command(p,"river",{method=method})
        assert(p.run.flags.river_crossed)
        command(p,"leave");assert(p.run.target==5)
    end
    for _,branch in ipairs({"ridge","gorge"}) do
        local p=depart(1);p.run.target=5;p.run.mode="landmark";p.run.progress=p.run.distance
        command(p,"leave",{branch=branch});assert(p.run.terrain==branch)
    end
end)
test("both recruits are retained and full crews cannot duplicate them",function()
    local p=depart(11)
    assert(model.debug(p,"event","slate_tracks"));command(p,"choice",{id="lever"})
    assert(model.debug(p,"event","slate_return"));command(p,"choice",{id="invite"})
    assert(#p.run.crew==3)
    assert(model.debug(p,"event","cinder_return"));local before=util.copy(p)
    assert(not model.command(p,"choice",{id="invite"}));assert_equal(p,before)
    command(p,"choice",{id="part"});command(p,"return")
    assert(p.profile.roster.slatewhorl and not p.profile.roster.cindercoil)
end)
test("all authored choices have a reachable resolution",function()
    for _,event in ipairs(model.events.defs) do
        for _,choice in ipairs(event.choices or {}) do
            local p=depart(7);local s=p.run
            if choice.species then s.crew[2]=progression.companion(choice.species);if s.crew[1].species==choice.species then s.crew[2]=progression.companion("loamling") end end
            assert(model.debug(p,"event",event.id));command(p,"choice",{id=choice.id})
            assert(s.mode~="event",event.id.." did not resolve")
        end
    end
end)
require("tests.combat")(test,command,valid,assert_equal)
require("tests.guardian")(test,command,valid,assert_equal)
require("tests.combat_costs")(test,command,valid,assert_equal)
require("tests.equipment")(test,command,valid,assert_equal)
require("tests.landscape")(test,assert_equal)
require("tests.playback")(test,command,valid,assert_equal)
require("tests.clarity")(test,command,valid,assert_equal)
require("tests.journey_choices")(test,command,valid,assert_equal)
require("tests.reporting")(test,assert_equal,journey)
print("OK "..passed.." tests")
