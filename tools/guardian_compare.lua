-- Fixed inputs, identical crews and downstream policies; no player saves.
local model=require "simulation.expedition"
local progression=require "simulation.progression"
local util=require "simulation.util"
local save=require "services.save"
local runner=require "tools.report.runner"
local json=require "tools.report.json"
local output={pattern=model.combat.GUARDIAN_PATTERN,matrix=json.array(),continuations=json.array(),journeys=json.array()}
for _,env in ipairs({{"meadow","clear"},{"ridge","rain"}}) do
    for _,energy in ipairs({100,16}) do
        for _,a in ipairs(model.species.order) do for _,b in ipairs(model.species.order) do
            if a~=b then for seed=1,20 do
                local initial=model.new(seed);initial.run.combat_effort=nil;assert(model.command(initial,"depart"))
                local s=initial.run;s.crew={progression.companion(a),progression.companion(b)}
                for _,c in ipairs(s.crew) do c.stamina=energy end
                s.terrain=env[1];s.weather=env[2]
                assert(model.debug(initial,"event","territorial"))
                for _,variant in ipairs({"current","authored","balanced"}) do
                    local p=util.copy(initial);s=p.run
                    if variant=="authored" then s.pending.pattern=model.combat.GUARDIAN_PATTERN end
                    if variant=="balanced" then s.combat_effort=model.combat.EFFORT end
                    assert(model.command(p,"choice",{id="battle"}));assert(model.command(p,"battle_start",{team={1,2}}))
                    while s.mode=="combat" do assert(model.command(p,"battle_step"));assert(save.validate(p)) end
                    local battle=s.battle;local harm,effort=0,0
                    for _,entry in ipairs(battle.history) do if entry.target~="cargo" then harm=harm+entry.damage end end
                    for _,c in ipairs(s.crew) do effort=effort+energy-c.stamina end
                    output.matrix[#output.matrix+1]={variant=variant,seed=seed,terrain=env[1],weather=env[2],energy=energy,
                        approach=a,wagon=b,outcome=battle.outcome,exchanges=#battle.history,
                        cargo_loss=-battle.result.cargo,condition_harm=harm,net_energy_spent=effort,detour_days=battle.result.days}
                end
            end end
        end end
    end
end
for _,strategy in ipairs({"careful","peaceful","fighter"}) do for seed=1,40 do
    local initial=model.new(seed);initial.run.combat_effort=nil
    local baseline,_,encounters=runner.run(initial,strategy,{capture=true})
    assert(baseline.status=="completed")
    local updated=runner.run(model.new(seed),strategy)
    assert(updated.status=="completed")
    output.journeys[#output.journeys+1]={seed=seed,strategy=strategy,
        original={outcome=baseline.outcome,final_day=baseline.final.day,recovery_days=baseline.totals.recovery_days},
        updated={outcome=updated.outcome,final_day=updated.final.day,recovery_days=updated.totals.recovery_days}}
    for _,encounter in ipairs(encounters) do if encounter.event=="territorial" then
        local matched={seed=seed,strategy=strategy,action=encounter.action,initial_snapshot=encounter.snapshot}
        for _,variant in ipairs({"current","authored","balanced"}) do
            local initial=util.copy(encounter.snapshot)
            if variant=="authored" then initial.run.pending.pattern=model.combat.GUARDIAN_PATTERN end
            -- This variant changes the combat version for the continuation,
            -- including later battles; the saved starting resources/policy match.
            if variant=="balanced" then initial.run.combat_effort=model.combat.EFFORT end
            local r=runner.run(initial,strategy,{intervention="fight"})
            assert(r.status=="completed",r.status)
            matched[variant]={outcome=r.outcome,final_day=r.final.day,cargo=r.final.cargo,
                recovery_days=r.totals.recovery_days,actions=r.actions,immediate=r.intervention_result}
        end
        output.continuations[#output.continuations+1]=matched
    end end
end end
print(json.encode(output))
