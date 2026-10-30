-- Deterministic balance evidence; stdout is CSV, suitable for a saved report.
package.path="./?.lua;./?/init.lua;"..package.path
local model=require "simulation.expedition"
local progression=require "simulation.progression"
local save=require "services.save"
print("seed,scenario,terrain,weather,approach,wagon,starting_energy,outcome,exchanges,cargo_loss,condition_loss,energy_spent,days,food_loss")
for _,kind in ipairs({"scavengers","territorial"}) do
    for _,env in ipairs({{"meadow","clear"},{"ridge","rain"}}) do
        for _,energy in ipairs({100,16}) do
            for _,a in ipairs(model.species.order) do
                for _,b in ipairs(model.species.order) do
                    for seed=1,20 do
                        local p=model.new(seed);assert(model.command(p,"depart"))
                        local s=p.run;s.crew={progression.companion(a)}
                        if a~=b then s.crew[2]=progression.companion(b) end
                        for _,c in ipairs(s.crew) do c.stamina=energy end
                        s.weather=env[2];s.terrain=env[1];s.encounter=kind;s.mode="combat_select"
                        assert(model.command(p,"battle_start",{team=#s.crew==2 and {1,2} or {1}}))
                        while s.mode=="combat" do assert(model.command(p,"battle_step"));assert(save.validate(p)) end
                        local battle=s.battle;local condition,effort=0,0
                        for _,i in ipairs(battle.team) do condition=condition-battle.result.crew[i].condition;effort=effort-battle.result.crew[i].stamina end
                        print(table.concat({seed,kind,env[1],env[2],a,a==b and "none" or b,energy,battle.outcome,#battle.history,-battle.result.cargo,condition,effort,battle.result.days,-battle.result.food},","))
                    end
                end
            end
        end
    end
end
