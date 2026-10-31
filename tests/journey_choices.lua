local model=require "simulation.expedition"
local save=require "services.save"
local util=require "simulation.util"
return function(test,command,valid,equal)
    local function event(id)
        local p=model.new(1848);command(p,"depart");assert(model.debug(p,"event",id));return p
    end
    test("combat inspection returns the exact event without rerolling or paying",function()
        for _,id in ipairs({"scavengers","territorial"}) do
            local p=event(id);local original=util.copy(p)
            for _=1,4 do
                command(p,"choice",{id="battle"});command(p,"battle_back");equal(p,original)
                command(p,"choice",{id="battle"});command(p,"battle_start",{team={1,2}})
                local intent=util.copy(p.run.battle.intent)
                p=util.copy(p);valid(p);command(p,"battle_back");equal(p,original)
                command(p,"choice",{id="battle"});command(p,"battle_start",{team={1,2}})
                equal(p.run.battle.intent,intent);command(p,"battle_back");equal(p,original)
            end
            local control=util.copy(original)
            command(p,"choice",{id=id=="scavengers" and "food" or "wait"})
            command(control,"choice",{id=id=="scavengers" and "food" or "wait"});equal(p,control)
        end
    end)
    test("first exchange commits setup and old setup saves remain usable",function()
        local p=event("scavengers");command(p,"choice",{id="battle"});command(p,"battle_start",{team={1,2}})
        local corrupt=util.copy(p);corrupt.run.return_rng=0;assert(not save.validate(corrupt))
        corrupt=util.copy(p);corrupt.run.pending.id="shortcut";assert(not save.validate(corrupt))
        command(p,"battle_step");assert(not p.run.pending and not p.run.return_rng)
        local before=util.copy(p);assert(not model.command(p,"battle_back"));equal(p,before)
        command(p,"withdraw");assert(p.run.battle.result.food==-8 and p.run.battle.result.cargo<=-8)
        p=event("scavengers");command(p,"choice",{id="battle"});p.run.pending=nil;valid(p)
        assert(not model.can_back_to_event(p.run));command(p,"battle_start",{team={1}});command(p,"withdraw")
        assert(p.run.mode=="combat_result")
    end)
    test("recruit food outlook matches actual crews and every ration setting",function()
        for _,id in ipairs({"cinder_return","slate_return"}) do
            for _,ration in ipairs({"sparse","normal","generous"}) do
                local p=event(id);p.run.food=70;p.run.rations=ration
                local before=util.copy(p);local choice=model.events.by_id[id].choices[1]
                local preview=model.events.recruit_preview(p.run,choice);equal(p,before)
                command(p,"choice",{id="invite"})
                assert(p.run.food==preview.food_after and model.resources.daily_food(p.run)==preview.meals_after)
                assert(model.forecast(p.run).days==preview.days_after)
                assert(preview.food_before==70 and preview.food_after==66)
                if id=="cinder_return" and ration=="normal" then assert(preview.meals_before==3 and preview.meals_after==4 and preview.days_before==23 and preview.days_after==16) end
            end
        end
    end)
    test("authored road receipts report actual costs and capped repair gains",function()
        local p=event("axle");p.run.wagon=99;local day=p.run.day
        command(p,"choice",{id="fix"});local text=p.run.log[#p.run.log].text
        assert(text:find("axle turns quietly",1,true) and text:find("Repair -1",1,true) and text:find("Wagon +1%",1,true))
        assert(not text:find("+12",1,true) and p.run.day==day)
        p=event("cinder_shelter");command(p,"choice",{id="help"});text=p.run.log[#p.run.log].text
        assert(text:find("trembling eases",1,true) and text:find("Medicine -1",1,true))
        assert(not text:find("follow",1,true))
        p=event("scavengers");command(p,"choice",{id="food"});text=p.run.log[#p.run.log].text
        assert(text:find("clear path",1,true) and text:find("Provisions -6",1,true))
    end)
    test("view speed is optional in older saves and changes no expedition state",function()
        local p=model.new(1848);p.settings.travel_speed=nil;valid(p)
        local before=util.copy(p.run);command(p,"settings",{key="travel_speed"})
        assert(p.settings.travel_speed==2);equal(p.run,before)
        p=util.copy(p);valid(p);command(p,"settings",{key="travel_speed"});assert(p.settings.travel_speed==1)
        for _,bad in ipairs({0,3,"brisk",false}) do p.settings.travel_speed=bad;assert(not save.validate(p)) end
    end)
end
