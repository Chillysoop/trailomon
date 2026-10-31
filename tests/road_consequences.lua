local model=require "simulation.expedition"
local util=require "simulation.util"
local save=require "services.save"
return function(test,command,valid,equal)
    local function event(id)
        local p=model.new(1848);command(p,"depart");p.run.target=3;p.run.distance=30;p.run.terrain="woodland"
        assert(model.debug(p,"event",id));return p
    end
    local function move(p)
        if p.run.road_story then command(p,"ack_story") end
        if p.run.mode=="stopped" then command(p,"resume") end
        command(p,"step")
    end
    test("cleared tree pays forward only at the next arrival and never twice",function()
        local p=event("tree");local s=p.run;local food=s.food;local rng=util.copy(s.rng)
        command(p,"choice",{id="haul"});assert(s.flags.road_cleared and not s.flags.road_repaid and not s.road_story)
        assert(s.food==food);equal(s.rng,rng)
        command(p,"rest");assert(not s.flags.road_repaid)
        s.progress=s.distance-1;food=s.food;move(p)
        assert(s.mode=="landmark" and s.flags.road_repaid and s.food==food-model.resources.daily_food(s)+6)
        assert(s.road_story:find("trunk you cleared",1,true) and s.road_story:find("pack 6",1,true))
        local before=util.copy(p);command(p,"ack_story");before.run.road_story=nil;equal(p,before)
        command(p,"rest");assert(not s.road_story)
        command(p,"leave");s.progress=s.distance-1;move(p);assert(not s.road_story)
        p=event("tree");command(p,"choice",{id="detour"});assert(not p.run.flags.road_cleared)
    end)
    test("thank-you food respects room after meals and tells the actual kept amount",function()
        local p=event("tree");command(p,"choice",{id="haul"});local s=p.run
        s.food=s.food+model.resources.capacity(s)-model.resources.weight(s)
        s.progress=s.distance-1;move(p)
        assert(model.resources.weight(s)==model.resources.capacity(s))
        assert(s.road_story:find("pack "..model.resources.daily_food(s),1,true))
        assert(s.flags.road_repaid)
    end)
    test("loose axle splits existing harm and fails once on rough travel",function()
        for _,terrain in ipairs({"woodland","ridge","gorge"}) do
            local p=event("axle");local s=p.run;command(p,"choice",{id="risk"})
            assert(s.wagon==94 and s.flags.axle_lashed and not s.road_story)
            s.terrain=terrain;s.cooldown=3;local baseline=util.copy(p);baseline.run.flags.axle_lashed=nil
            move(p);move(baseline)
            assert(math.abs(baseline.run.wagon-s.wagon-6)<0.00001)
            assert(not s.flags.axle_lashed and s.mode=="stopped" and s.road_story:find("lashed earlier",1,true))
            local before=util.copy(p);command(p,"ack_story");before.run.road_story=nil;equal(p,before)
            baseline=util.copy(p);move(p);move(baseline);equal(p,baseline)
        end
        local p=event("axle");command(p,"choice",{id="risk"});p.run.wagon=7;p.run.terrain="ridge";p.run.rng.weather=30000
        move(p);assert(p.run.wagon==0 and p.run.road_story:find("Wagon -5.6",1,true))
    end)
    test("smooth travel and camp leave lashing pending but repairs prevent the follow-up",function()
        local p=event("axle");local s=p.run;command(p,"choice",{id="risk"})
        s.terrain="meadow";s.rng.weather=30000;s.cooldown=3
        move(p);assert(s.weather=="clear" and s.flags.axle_lashed and not s.road_story)
        command(p,"pause");command(p,"rest");assert(s.flags.axle_lashed)
        local days=s.day;local materials=s.repairs;command(p,"repair")
        assert(s.day==days+1 and s.repairs==materials-1 and not s.flags.axle_lashed)
        assert(s.road_story:find("prevented",1,true))
        command(p,"ack_story");s.terrain="ridge";move(p);assert(not s.road_story)
        p=event("axle");command(p,"choice",{id="fix"});assert(not p.run.flags.axle_lashed)
    end)
    test("consequences survive checkpoints without duplicated effects or hidden RNG draws",function()
        for _,id in ipairs({"tree","axle"}) do
            local p=event(id);command(p,"choice",{id=id=="tree" and "haul" or "risk"})
            p.run.progress=p.run.distance-1
            local resumed=util.copy(p);valid(resumed);move(p);move(resumed);equal(p,resumed)
            assert(p.run.road_story);resumed=util.copy(p);valid(resumed)
            command(p,"ack_story");command(resumed,"ack_story");equal(p,resumed)
        end
        local p=event("axle");command(p,"choice",{id="risk"});p.run.terrain="meadow";p.run.rng.weather=1
        move(p);assert(p.run.weather=="rain" and not p.run.flags.axle_lashed and p.run.road_story)
    end)
    test("combined arrival stories preserve both causes and final results",function()
        local p=event("tree");command(p,"choice",{id="haul"});assert(model.debug(p,"event","axle"));command(p,"choice",{id="risk"})
        local s=p.run;s.progress=s.distance-1;move(p)
        assert(s.mode=="landmark" and s.road_story:find("lashed earlier",1,true) and s.road_story:find("trunk you cleared",1,true))
        command(p,"ack_story");s.mode="stopped";s.target=6;s.terrain="ridge";s.progress=s.distance-1;s.flags.axle_lashed=true
        move(p);assert(s.mode=="result" and s.road_story)
        local before=util.copy(p);command(p,"ack_story");before.run.road_story=nil;equal(p,before)
        command(p,"new");assert(not p.run.flags.road_cleared and not p.run.flags.axle_lashed and not p.run.road_story)
    end)
    test("old saves have no retroactive consequences and new optional fields are validated",function()
        local p=event("axle");p.run.flags={};valid(p)
        p.run.wagon=88;p.run.mode="stopped";p.run.pending=nil;move(p);assert(not p.run.road_story)
        for _,key in ipairs({"road_cleared","road_repaid","axle_lashed"}) do
            local bad=util.copy(p);bad.run.flags[key]="true";assert(not save.validate(bad))
        end
        for _,bad_value in ipairs({true,8,string.rep("x",1001)}) do
            local bad=util.copy(p);bad.run.road_story=bad_value;assert(not save.validate(bad))
        end
    end)
end
