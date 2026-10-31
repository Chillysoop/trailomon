-- Focused resource-economy check. Frozen reference policies, not optimal players.
-- Run with the pinned LuaJIT from the repo root; stdout is reproducible JSON.
package.path="./?.lua;./?/init.lua;"..package.path
local model=require "simulation.expedition"
local runner=require "tools.report.runner"
local json=require "tools.report.json"
local save=require "services.save"
local rows=json.array()
for _,strategy in ipairs({"careful","peaceful","fighter"}) do
    for _,item in ipairs({"none","padded_trace","release_rope","dry_wrap"}) do
        local row={strategy=strategy,item=item,runs=12,delivered=0,late=0,rescued=0,days=0,cargo=0,recovery_days=0}
        for seed=1,12 do
            local initial=model.new(seed)
            if item~="none" then
                assert(model.command(initial,"buy_work_item",{item=item}))
                assert(model.command(initial,"equip_work_item",{item=item,member=1}))
            end
            local report,p=runner.run(initial,strategy)
            local replay,q=runner.run(initial,strategy)
            assert(report.status=="completed",json.encode(report.failure))
            assert(json.encode(report)==json.encode(replay) and json.encode(p)==json.encode(q),"Replay diverged")
            assert(save.validate(p))
            row[p.run.outcome]=row[p.run.outcome]+1
            row.days=row.days+p.run.day;row.cargo=row.cargo+p.run.cargo
            row.recovery_days=row.recovery_days+report.totals.recovery_days
        end
        row.mean_day=row.days/row.runs;row.mean_cargo=row.cargo/row.runs
        row.days=nil;row.cargo=nil
        rows[#rows+1]=row
    end
end
print(json.encode({schema=1,seeds="1..12",crew={"brindlehorn","loamling"},wearer="approach/hauler",policy="reference-v1",runs=144,repeated_exactly=true,rows=rows}))
