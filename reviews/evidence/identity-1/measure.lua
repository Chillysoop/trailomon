-- Run from the repository root: .tools/luajit-64.exe reviews/evidence/identity-1/measure.lua
-- Simulation-command shares are not human playtime. No player saves are used.
package.path='./?.lua;./?/init.lua;'..package.path
local model=require 'simulation.expedition'
local runner=require 'tools.report.runner'
local policy=require 'tools.report.policy'
local tracking=require 'simulation.tracking'
local discovery=require 'simulation.discovery'
local json=require 'tools.report.json'
local cohorts={
 {id='classic_peaceful',strategy='peaceful'},
 {id='classic_fighter',strategy='fighter'},
 {id='classic_fighter_practice',strategy='fighter',practice=true},
 {id='discovery_brindle_peaceful',strategy='peaceful',starter='brindlehorn'},
 {id='discovery_brindle_fighter_practice',strategy='fighter',starter='brindlehorn',meet=true,practice=true},
 {id='discovery_reed_fighter_practice',strategy='fighter',starter='reedskipper',meet=true,practice=true},
 {id='discovery_brindle_explorer',strategy='fighter',starter='brindlehorn',meet=true,search=true,practice=true},
 {id='discovery_reed_explorer',strategy='fighter',starter='reedskipper',meet=true,search=true,practice=true},
}
local output={version=1,seed_first=1,seed_last=24,cohorts=json.array(),runs=json.array()}
for _,cohort in ipairs(cohorts) do
 local function next_action(p,strategy)
  local s=p.run
  if not s.road_story then
   if cohort.practice and s.mode=='landmark' and s.target==3 and not s.flags.courier_done then return 'courier',{},'accept optional practice' end
   if cohort.search and tracking.preview(p).available then return 'follow_tracks',{},'follow each available clue' end
   if cohort.meet and discovery.invitation(p) then return 'meet_wild',{},'meet missing hauler if offered' end
  end
  return policy.next(p,strategy)
 end
 local aggregate={id=cohort.id,runs=24,battles=0,exchanges=0,actions=0,combat_actions=0,travel_days=0,searches=0,zero_battle_runs=0,min_battles=99,max_battles=0,outcomes={},by_kind={},repeated_exactly=true}
 for seed=1,24 do
  local initial=model.new(seed,cohort.starter and 'discovery' or nil)
  if cohort.starter then assert(model.command(initial,'starter',{species=cohort.starter})) end
  local options={policy=next_action,max_actions=350,stall_visits=3}
  local report=runner.run(initial,cohort.strategy,options)
  local repeat_report=runner.run(initial,cohort.strategy,options)
  assert(report.status=='completed',json.encode(report.failure))
  assert(json.encode(report)==json.encode(repeat_report),'Replay mismatch')
  local row={cohort=cohort.id,seed=seed,outcome=report.outcome,ending=report.final_snapshot.run.ending,day=report.final.day,actions=report.actions,battles=0,exchanges=report.totals.combat_exchanges,combat_actions=0,searches=0,by_kind={}}
  for _,step in ipairs(report.steps) do
   local id=step.command
   if id=='battle_start' then
    row.battles=row.battles+1
    local kind=step.after.battle.kind;row.by_kind[kind]=(row.by_kind[kind] or 0)+1
   end
   if id=='follow_tracks' then row.searches=row.searches+1 end
   if id=='courier' or id=='battle_start' or id=='battle_step' or id=='battle_continue' or id=='withdraw' or (id=='choice' and step.after.mode=='combat_select') then row.combat_actions=row.combat_actions+1 end
  end
  for _,k in ipairs({'battles','exchanges','actions','combat_actions','searches'}) do aggregate[k]=aggregate[k]+row[k] end
  aggregate.travel_days=aggregate.travel_days+report.totals.travel_ticks
  aggregate.zero_battle_runs=aggregate.zero_battle_runs+(row.battles==0 and 1 or 0)
  aggregate.min_battles=math.min(aggregate.min_battles,row.battles);aggregate.max_battles=math.max(aggregate.max_battles,row.battles)
  aggregate.outcomes[row.outcome]=(aggregate.outcomes[row.outcome] or 0)+1
  for kind,n in pairs(row.by_kind) do aggregate.by_kind[kind]=(aggregate.by_kind[kind] or 0)+n end
  output.runs[#output.runs+1]=row
 end
 aggregate.combat_command_percent=100*aggregate.combat_actions/aggregate.actions
 aggregate.mean_battles=aggregate.battles/24;aggregate.mean_exchanges=aggregate.exchanges/24
 output.cohorts[#output.cohorts+1]=aggregate
end
io.write(json.encode(output),'\n')
