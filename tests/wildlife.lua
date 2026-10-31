local model=require "simulation.expedition"
local guide=require "simulation.field_guide"
local util=require "simulation.util"
return function(test,command,valid,equal)
    test("wildlife habitats, cooldown and recruitment priority",function()
        local p=model.new(144);local s=p.run;s.cooldown=0;s.terrain="woodland";s.target=3
        assert(model.events.eligible(s,model.events.by_id.wild_bellmoth,p.profile))
        assert(not model.events.eligible(s,model.events.by_id.wild_brindlehorn,p.profile))
        s.flags.cinder_helped=true
        for seed=1,30 do s.rng.events=seed;assert(model.events.select(s,p.profile).id=="cinder_return") end
        s.flags.cinder_helped=nil;s.cooldown=1
        for seed=1,30 do s.rng.events=seed;local e=model.events.select(s,p.profile);assert(not e or e.kind=="ambient") end
        s.cooldown=0;s.wildlife_rules=nil
        assert(not model.events.eligible(s,model.events.by_id.wild_bellmoth,p.profile))
    end)
    test("wildlife journeys finish and checkpoint deterministically",function()
        local runner=require "tools.report.runner"
        for seed=1,12 do for _,strategy in ipairs({"careful","peaceful","fighter"}) do
            local initial=model.new(seed);local a=runner.run(initial,strategy);local b=runner.run(initial,strategy)
            assert(a.status=="completed");equal(a,b)
        end end
    end)
    test("field notes distinguish starters, watching and traveling",function()
        local p=model.new(44);local rows=guide.rows(p)
        assert(rows[1].known and not rows[1].seen and not rows[1].traveled)
        command(p,"depart");assert(model.debug(p,"event","wild_brindlehorn"))
        local before=util.copy(p.run);command(p,"choice",{id="watch"})
        assert(p.run.observations.brindlehorn and p.run.food==before.food and p.run.day==before.day)
        assert(p.run.cooldown==3 and not model.events.eligible(p.run,model.events.by_id.wild_brindlehorn,p.profile))
        local resumed=util.copy(p);valid(resumed);command(p,"return");command(resumed,"return");equal(p,resumed)
        assert(p.profile.observations.brindlehorn and p.profile.traveled.brindlehorn and p.run.new_observations.brindlehorn)
        command(p,"new");assert(not p.run.observations and guide.rows(p)[1].seen)
    end)
    test("existing wildlife records observations without battle",function()
        local p=model.new(4);command(p,"depart");assert(model.debug(p,"event","scavengers"))
        assert(p.run.observations.loamling);command(p,"choice",{id="food"});command(p,"return")
        assert(p.profile.observations.loamling)
        local old=model.new(4);old.run.wildlife_rules=nil;old.profile.observations=nil;old.profile.traveled=nil;valid(old)
        old.profile.observations={dragon=true};assert(not require("services.save").validate(old))
    end)
end
