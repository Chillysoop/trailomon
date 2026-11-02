-- S30 comparison: same seeds, routes, supplies and reference decisions.
-- Only the new-run road rules marker differs. Times are simulation, not playtime.
package.path="./?.lua;./?/init.lua;"..package.path
local model=require "simulation.expedition"
local runner=require "tools.report.runner"
local json=require "tools.report.json"
local util=require "simulation.util"
local out={schema=1,seeds="1:40",policy=require("tools.report.policy").VERSION,rows=json.array(),groups=json.array(),peaceful_exact=0}
for _,mode in ipairs({"classic","discovery"}) do for _,strategy in ipairs({"careful","peaceful","fighter"}) do
    local prior={}
    for _,rules in ipairs({"previous","wagon-road-v1"}) do
        local group={mode=mode,strategy=strategy,rules=rules,runs=0,outcomes={},days=0,battles=0,seconds=0,wins=0}
        for seed=1,40 do
            local p=model.new(seed,mode);if rules=="previous" then p.run.road_combat_rules=nil end
            local report,final=runner.run(p,strategy);assert(report.status=="completed",report.failure and report.failure.message)
            local repeat_report,repeat_final=runner.run(p,strategy);assert(json.encode(final)==json.encode(repeat_final))
            local battles,wins=0,0
            for _,step in ipairs(report.steps) do
                if step.command=="road_continue" or step.command=="battle_continue" then
                    battles=battles+1
                    if step.before.battle.outcome=="victory" or step.before.battle.outcome=="won" then wins=wins+1 end
                end
            end
            group.runs=group.runs+1;group.days=group.days+final.run.day;group.battles=group.battles+battles;group.wins=group.wins+wins
            group.seconds=group.seconds+(report.totals.combat_seconds or 0)
            group.outcomes[final.run.outcome]=(group.outcomes[final.run.outcome] or 0)+1
            out.rows[#out.rows+1]={mode=mode,strategy=strategy,rules=rules,seed=seed,outcome=final.run.outcome,
                day=final.run.day,cargo=final.run.cargo,food=final.run.food,wagon=final.run.wagon,battles=battles,wins=wins,seconds=report.totals.combat_seconds or 0,actions=report.actions}
            if strategy=="peaceful" then
                local normalized=util.copy(final);normalized.run.road_combat_rules=nil
                if rules=="previous" then prior[seed]=json.encode(normalized)
                else assert(prior[seed]==json.encode(normalized),"Peaceful route changed");out.peaceful_exact=out.peaceful_exact+1 end
            end
        end
        out.groups[#out.groups+1]=group
    end
end end
print(json.encode(out))
