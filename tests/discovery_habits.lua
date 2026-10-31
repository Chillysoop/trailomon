local model=require "simulation.expedition"
local util=require "simulation.util"
local progression=require "simulation.progression"
local habits=require "simulation.habits"
return function(test,command,valid,equal)
    test("discovery starters preserve normal depots and recruit without a soft-lock",function()
        for _,id in ipairs({"brindlehorn","reedskipper"}) do
            local p=model.new(3,"discovery");command(p,"starter",{species=id});valid(p)
            assert(#p.run.crew==1 and p.profile.roster[id] and not p.profile.roster.loamling)
            command(p,"depart");assert(not model.command(p,"starter",{species="brindlehorn"}))
            for _,species in ipairs({"loamling","bellmoth"}) do
                assert(model.debug(p,"event","discover_"..species));local preview=model.events.recruit_preview(p.run,model.events.by_id['discover_'..species].choices[1])
                command(p,"choice",{id="invite"});assert(p.run.food==preview.food_after)
            end
            assert(#p.run.crew==3);local saved=util.copy(p);command(p,"return");command(saved,"return");equal(p,saved)
            command(p,"new");assert(p.run.crew[1].species==id and #p.run.crew==2);valid(p)
        end
        local normal=model.new(3);assert(normal.profile.roster.loamling and normal.profile.roster.bellmoth)
        assert(not model.command(normal,"starter",{species="reedskipper"}))
    end)
    test("habits unlock on work not camping and select only at departure",function()
        local p=model.new(5);command(p,"depart");local c=p.run.crew[1]
        command(p,"rest");assert(not c.habit_days)
        for _=1,3 do model.advance_day(p,true,false) end
        assert(c.habit_days==3 and not c.habit);assert(not model.command(p,"habit",{species=c.species}))
        command(p,"return");command(p,"new");command(p,"habit",{species="brindlehorn"})
        assert(p.run.crew[1].habit and p.profile.roster.brindlehorn.habit)
        command(p,"habit",{species="brindlehorn"});assert(not p.run.crew[1].habit)
        local bad=util.copy(p);bad.run.crew[1].habit=true;bad.run.crew[1].habit_days=2;assert(not require("services.save").validate(bad))
    end)
    test("habit costs include their drawbacks and equipment without stacking",function()
        local p=model.new(9);local s=p.run;local a=s.crew[1];a.habit_days=3;a.habit=true
        s.pace="hurried";s.work_items={padded_trace=true};a.work_item="padded_trace"
        assert(model.resources.haul_effort(s,a)==6 and habits.speed(a)==0.96)
        local l=s.crew[2];l.habit_days=3;l.habit=true;l.stamina=12
        local preview=model.forage_preview(s);assert(preview.effort==12 and preview.gross==16 and preview.member==l)
        for _,id in ipairs({"bellmoth","cindercoil","reedskipper"}) do
            local c=progression.companion(id);c.habit_days=3;c.habit=true;s.crew[2]=c
            assert(habits.cost(c,"event",18)==14)
            if id~="reedskipper" then assert(habits.upkeep(c)==0.5) else assert(habits.cost(c,"river",22)==18 and habits.dry_haul(c)==1) end
        end
    end)
    test("habit previews match gathering assistance crossing and travel",function()
        local p=model.new(5);command(p,"depart");local s=p.run
        local c=s.crew[2];c.habit_days=3;c.habit=true;c.stamina=12
        local before=s.food;local preview=model.forage_preview(s);command(p,"forage");assert(s.food-before==preview.net)
        p=model.new(5);command(p,"depart");s=p.run;s.crew[2]=progression.companion("bellmoth")
        c=s.crew[2];c.habit_days=3;c.habit=true;c.stamina=10
        assert(model.debug(p,"event","tree"));local choice=model.events.by_id.tree.choices[2]
        assert(model.events.cost_text(s,choice):find("10 energy"));command(p,"choice",{id="scout"});assert(c.stamina==0)
        p=model.new(5);command(p,"depart");s=p.run;s.crew[2]=progression.companion("reedskipper")
        c=s.crew[2];c.habit_days=3;c.habit=true;c.stamina=18;s.mode="landmark";s.target=4;s.progress=s.distance
        local helper,_,cost=model.crossing_helper(s,"swim");assert(helper==c and cost==18);command(p,"river",{method="swim"});assert(s.flags.river_crossed)
        p=model.new(5);command(p,"depart");s=p.run;c=s.crew[1];c.habit_days=3;c.habit=true
        local off=util.copy(p);off.run.crew[1].habit=nil
        assert(model.advance_day(p,true,false));assert(model.advance_day(off,true,false))
        assert(math.abs(s.progress-off.run.progress*0.96)<0.00001)
        assert(s.crew[1].stamina==off.run.crew[1].stamina+2)
    end)
    test("profile switching stops when the current save fails",function()
        local save=require "services.save";local write=save.write
        save.write=function() return false,"No space" end
        local p=model.new(1);local before=util.copy(p);local other,why=save.select(p,"discovery")
        save.write=write
        assert(not other and why=="No space" and save.slot()=="classic");equal(p,before)
    end)
    test("discovery and habit journeys finish with repeatable saved outcomes",function()
        local runner=require "tools.report.runner";local totals={}
        for _,starter in ipairs({"brindlehorn","reedskipper"}) do
            totals[starter]={}
            for seed=1,16 do for _,learned in ipairs({false,true}) do
                local p=model.new(seed,"discovery");command(p,"starter",{species=starter})
                if learned then p.run.crew[1].habit_days=3;p.run.crew[1].habit=true end
                local a=runner.run(p,"careful");local b=runner.run(p,"careful");equal(a,b);assert(a.status=="completed")
                local key=(learned and "habit " or "plain ")..a.outcome;totals[starter][key]=(totals[starter][key] or 0)+1
            end end
            for key,n in pairs(totals[starter]) do print("  discovery "..starter.." / "..key..": "..n) end
        end
    end)
end
