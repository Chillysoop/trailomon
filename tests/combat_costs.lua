local model=require "simulation.expedition"
local util=require "simulation.util"
local save=require "services.save"
local progression=require "simulation.progression"
local runner=require "tools.report.runner"
return function(test,command,valid,equal)
    local function encounter(kind,energy,legacy)
        local p=model.new(1848)
        if legacy then p.run.combat_effort=nil end
        command(p,"depart")
        p.run.crew={progression.companion("brindlehorn"),progression.companion("loamling")}
        for _,c in ipairs(p.run.crew) do c.stamina=energy or 100 end
        assert(model.debug(p,"event",kind));command(p,"choice",{id="battle"})
        command(p,"battle_start",{team={1,2}});return p
    end
    test("new journeys use reduced effort and the authored guardian; old journeys retain rules",function()
        local p=encounter("territorial");local old=encounter("territorial",100,true)
        assert(p.run.battle.pattern==model.combat.GUARDIAN_PATTERN and old.run.battle.pattern==nil)
        assert(p.run.battle.effort==model.combat.EFFORT and old.run.battle.effort==nil)
        command(p,"battle_step");command(old,"battle_step")
        assert(p.run.crew[1].stamina==91 and p.run.crew[2].stamina==97)
        assert(old.run.crew[1].stamina==88 and old.run.crew[2].stamina==96)
        assert(p.run.battle.intent.kind=="warning" and old.run.battle.intent.kind=="heavy")
        local before=util.copy(p);local preview=model.combat.preview(p.run);equal(p,before)
        assert(preview.energy[1]==1 and preview.energy[2]==1)
        command(p,"battle_step");assert(p.run.crew[1].stamina==90 and p.run.crew[2].stamina==96)
    end)
    test("tired guardian crews finish without a warning-induced energy collapse",function()
        local p=encounter("territorial",16);local rng=util.copy(p.run.rng)
        while p.run.mode=="combat" do
            local copy=util.copy(p);valid(copy)
            command(copy,"battle_step");command(p,"battle_step");equal(p,copy)
        end
        assert(p.run.battle.outcome=="won" and #p.run.battle.history==4)
        assert(p.run.crew[1].stamina==0 and p.run.crew[2].stamina==0)
        assert(p.run.cargo==100 and p.run.crew[1].condition==94)
        equal(rng,p.run.rng)
    end)
    test("new effort thresholds reject exhausted entry and do not grant free abilities",function()
        local p=encounter("scavengers",9)
        local preview=model.combat.preview(p.run);assert(preview.energy[1]==9 and preview.abilities[1].code=="trigger")
        p.run.crew[1].stamina=8
        preview=model.combat.preview(p.run);assert(preview.energy[1]==3 and preview.abilities[1].code=="energy")
        assert(preview.abilities[1].text=="Needs 9 energy before exchange")
        p.run.crew[1].stamina=2
        preview=model.combat.preview(p.run);assert(preview.energy[1]==0)
        command(p,"battle_back");command(p,"choice",{id="battle"})
        local before=util.copy(p);assert(not model.command(p,"battle_start",{team={1}}));equal(p,before)
        p.run.crew[1].stamina=3;command(p,"battle_start",{team={1}})
        command(p,"battle_step");assert(p.run.battle.outcome=="fallback")
    end)
    test("effort versions survive free inspection and reject unknown save values",function()
        local p=encounter("territorial",16);local before=util.copy(p)
        command(p,"battle_back");command(p,"choice",{id="battle"});command(p,"battle_start",{team={1,2}})
        equal(p,before)
        local bad=util.copy(p);bad.run.combat_effort="future";assert(not save.validate(bad))
        bad=util.copy(p);bad.run.battle.effort="future";assert(not save.validate(bad))
        local old=encounter("territorial",100,true);local oldcopy=util.copy(old)
        while old.run.mode=="combat" do command(old,"battle_step");command(oldcopy,"battle_step");equal(old,oldcopy) end
    end)
    test("new-cost reference journeys finish and repeat with unchanged peaceful outcomes",function()
        local counts={}
        for _,strategy in ipairs({"careful","peaceful","fighter"}) do
            counts[strategy]=0
            for seed=1,40 do
                -- Keep this historical cost-only benchmark on its original event rules.
                local initial=model.new(seed);initial.run.wildlife_rules=nil
                local a=runner.run(initial,strategy);local b=runner.run(initial,strategy)
                assert(a.status=="completed");equal(a,b)
                if a.outcome=="delivered" then counts[strategy]=counts[strategy]+1 end
            end
        end
        assert(counts.careful==23 and counts.peaceful==14)
        assert(counts.fighter==6 and counts.fighter<counts.peaceful,"Unexpected new-cost benchmark outcome")
        print("  new-cost deliveries: careful "..counts.careful..", peaceful "..counts.peaceful..", fighter "..counts.fighter)
    end)
end
