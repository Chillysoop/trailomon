local model=require "simulation.expedition"
local util=require "simulation.util"
return function(test,command,valid,equal)
    test("encounter entry uses the same energy threshold as battle setup",function()
        for _,legacy in ipairs({false,true}) do
            local p=model.new(9);command(p,"depart");if legacy then p.run.combat_effort=nil end
            local energy=model.combat.costs(p.run)
            for _,c in ipairs(p.run.crew) do c.stamina=energy-1 end
            assert(model.debug(p,"event","scavengers"))
            local choice=model.events.by_id.scavengers.choices[3]
            assert(not model.events.available(p.run,choice,p.profile))
            p.run.crew[1].stamina=energy;assert(model.events.available(p.run,choice,p.profile))
            command(p,"choice",{id="battle"});command(p,"battle_start",{team={1}})
            valid(p)
        end
    end)
    test("exhausted and unfed crews can withdraw directly with the existing cost once",function()
        for _,event in ipairs({"scavengers","territorial"}) do
            local p=model.new(9);command(p,"depart");p.run.food=0
            for _,c in ipairs(p.run.crew) do c.stamina=0 end
            assert(model.debug(p,"event",event));local before=util.copy(p)
            command(p,"withdraw");assert(not p.run.pending and not p.run.encounter)
            assert(p.run.day==before.run.day+(event=="territorial" and 1 or 0))
            assert(p.run.cargo==before.run.cargo-(event=="scavengers" and 8 or 0))
            assert(not p.run.aim_journey.fought and p.run.food==0)
            local after=util.copy(p);assert(not model.command(p,"withdraw"));equal(p,after)
            local rope=model.new(9);command(rope,"buy_work_item",{item="release_rope"});command(rope,"equip_work_item",{item="release_rope",member=1})
            command(rope,"depart");assert(model.debug(rope,"event",event));command(rope,"withdraw")
            if event=="scavengers" then assert(rope.run.cargo==96 and rope.run.food==86) end
        end
        local p=model.new(9);command(p,"depart");assert(model.debug(p,"event","tree"))
        local before=util.copy(p);assert(not model.command(p,"withdraw"));equal(p,before)
    end)
    test("terminal travel clamps distance before rescue and stays saveable",function()
        for _,cause in ipairs({"closure","hunger"}) do for _,target in ipairs({3,6}) do
            local p=model.new(1848);command(p,"depart");local s=p.run
            s.target=target;s.distance=35;s.progress=34.5;s.terrain="gorge";s.rng.weather=30000
            if cause=="closure" then s.day=31 else s.food=0;s.traveler=1 end
            command(p,"resume");local copy=util.copy(p)
            command(p,"step");command(copy,"step");equal(p,copy)
            assert(s.mode=="result" and s.outcome=="rescued" and s.progress==s.distance)
            assert(not p.profile.aims.completed.peaceful,"Rescue must still precede arrival awards")
            valid(p);local before=util.copy(p);assert(not model.command(p,"step"));equal(p,before)
        end end
    end)
end
