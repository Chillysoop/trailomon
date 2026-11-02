-- Visible-state Discovery policies. No hidden track results, RNG or look-ahead.
package.path="./?.lua;./?/init.lua;"..package.path
local model=require "simulation.expedition"
local runner=require "tools.report.runner"
local reference=require "tools.report.policy"
local json=require "tools.report.json"
local util=require "simulation.util"
local tracking=require "simulation.tracking"
local combat=require "simulation.wagon_combat"
local discovery=require "simulation.discovery"
local M={VERSION="discovery-s5-v1"}
M.configs={
 {id="steady_0",searches=0}, {id="steady_2",searches=2},
 {id="adaptive_0",adaptive=true,searches=0}, {id="adaptive_2",adaptive=true,searches=2},
 {id="adaptive_all",adaptive=true,searches=5},
 {id="meadow_2",adaptive=true,searches=2,meadow=true},
 {id="solo_2",adaptive=true,searches=2,solo=true},
 {id="fight_2",adaptive=true,searches=2,fight=true},
 {id="fight_no_supplies_2",adaptive=true,searches=2,fight=true,no_supplies=true},
 {id="trace_2",adaptive=true,searches=2,trace=true},
}
local function choose(p,predicate)
 for _,c in ipairs(model.events.by_id[p.run.pending.id].choices) do
  if predicate(c) and model.events.available(p.run,c,p.profile) then return c end
 end
end
function M.policy(c)
 return function(p)
  local s=p.run;local res=model.resources
  if s.road_story then return "ack_story",{},"read consequence" end
  if s.mode=="preparation" then return "depart",{},"fresh solo Discovery start" end
  if s.mode=="event" then
   local event=model.events.by_id[s.pending.id];local pick
   if event.kind=="encounter" then
    local healthy=0;for _,u in ipairs(s.crew) do if u.condition>=50 and u.stamina>=12 then healthy=healthy+1 end end
    if c.fight or healthy>=2 then pick=choose(p,function(x)return x.battle end) end
    pick=pick or choose(p,function(x)return not x.battle and x.species end) or choose(p,function(x)return not x.battle end)
    if not pick then return "withdraw",{},"no affordable peaceful approach" end
   elseif event.kind=="courier" then pick=choose(p,function(x)return x.id=="pass" end)
   elseif c.solo then pick=choose(p,function(x)return not x.recruit and not x.battle end)
   else pick=choose(p,function(x)return not x.battle end) end
   assert(pick,"No event choice");return "choice",{id=pick.id},"recruit when possible; fight with two healthy companions"
  end
  if s.mode=="wagon_combat" then
   local b=s.wagon_battle.battle
   if b.phase=="fight" and not c.no_supplies then
    local target=combat.supply_target(b,"medicine")
    if target and target.hp<=target.max_hp-28 then return "road_supply",{id="medicine"},"one carried medicine on a wounded living ally" end
    if combat.supply_target(b,"repairs") and b.wagon.hp<=65 then return "road_supply",{id="repairs"},"one carried repair protects the wagon" end
   end
   return reference.next(p,"fighter")
  end
  if s.mode=="stopped" or s.mode=="traveling" or s.mode=="landmark" then
   if s.mode=="landmark" and not c.solo and discovery.invitation(p) then return "meet_wild",{},"meet available hauler" end
   if s.traveler<45 and s.medicine>0 then return "treat",{},"traveler needs care" end
   local hauler=s.crew[s.hauler]
   for i,u in ipairs(s.crew) do
    if i~=s.hauler and model.species.defs[u.species].draft and res.ready(u,20)
      and (hauler.condition<=0 or u.stamina>hauler.stamina+20) then return "hauler",{member=i},"rotate to a rested draft companion" end
   end
   for i,u in ipairs(s.crew) do if u.condition<55 and s.medicine>0 then return "treat",{member=i},"restore injured companion" end end
   if s.wagon<35 and s.repairs>0 then return "repair",{},"repair before losing road access" end
   if s.mode=="landmark" and s.target==3 and s.food<75 and s.coins>=6 and res.weight(s)+10<=res.capacity(s) then return "buy",{item="food"},"last shop / food for the high road" end
   if s.food<res.daily_food(s)*3 and model.forage_preview(s).net>0 then return "forage",{},"food below three days" end
   if not res.hauler(s) or hauler.stamina<18 or hauler.condition<25 then return "rest",{},"hauler needs recovery" end
   local pace=c.adaptive and hauler.stamina>=35 and "hurried" or "steady"
   if s.pace~=pace then return "policy",{key="pace",value=pace},"adapt pace to visible energy" end
   local searched=0;for _,t in pairs(s.tracks or {}) do if t.used then searched=searched+1 end end
   local clue=tracking.preview(p)
   if searched<c.searches and clue.available and (c.searches==5 or s.target==3 or s.target==5)
    and s.food>=res.daily_food(s)*4 then return "follow_tracks",{},"budgeted exploration on woodland/upland stretch" end
   if s.mode=="landmark" then
    if s.target==4 and not s.flags.river_inspected then return "river",{method="inspect"},"inspect crossing" end
    if s.target==4 and not s.flags.river_crossed then return "river",{method=s.coins>=12 and "ferry" or "rope"},"ferry if affordable" end
    return "leave",{branch=s.target==2 and (c.meadow and "meadow" or "woodland") or "ridge"},"fixed route"
   end
   if s.mode=="stopped" then return "resume",{},"ready" end
   return "step",{},"travel day"
  end
  return reference.next(p,"careful")
 end
end
function M.initial(seed,starter,c,legacy)
 local p
 if starter=="classic" then p=model.new(seed)
 else p=model.new(seed,"discovery");assert(model.command(p,"starter",{species=starter})) end
 if legacy then p.run.recovery_rules=nil end
 if c.trace then assert(model.command(p,"buy_work_item",{item="padded_trace"}));assert(model.command(p,"equip_work_item",{item="padded_trace",member=1})) end
 return p
end
function M.run(seeds,compare,classic)
 local out={schema=1,policy=M.VERSION,seeds="1:"..seeds,rows=json.array(),groups=json.array(),samples=json.array()}
 local configs=classic and {M.configs[2],M.configs[4],M.configs[8],M.configs[10]} or M.configs
 for _,rules in ipairs(compare and {"previous","current"} or {"current"}) do
 for _,starter in ipairs(classic and {"classic"} or {"brindlehorn","reedskipper"}) do for _,c in ipairs(configs) do
  local group={rules=rules,starter=starter,policy=c.id,runs=0,outcomes={},days=0,recovery=0,searches=0,battles=0,wins=0,recovery_food=0,cargo=0}
  for seed=1,seeds do
   local initial=M.initial(seed,starter,c,rules=="previous")
   local r,p=runner.run(initial,c.id,{policy=M.policy(c),max_actions=400})
   assert(r.status=="completed",c.id.." "..starter.." "..seed.." "..json.encode(r.failure))
   local rr,pp=runner.run(initial,c.id,{policy=M.policy(c),max_actions=400})
   assert(rr.status=="completed" and json.encode(p)==json.encode(pp),"Replay diverged")
   local battles,wins,searches,food=0,0,0,0
   for _,step in ipairs(r.steps) do
    if step.command=="road_continue" then battles=battles+1;if step.before.battle.outcome=="victory" then wins=wins+1 end end
    if step.command=="follow_tracks" then searches=searches+1 end
    if step.command=="rest" or step.command=="treat" or step.command=="repair" then food=food-step.delta.food end
   end
   local row={rules=rules,starter=starter,policy=c.id,seed=seed,outcome=p.run.outcome,day=p.run.day,
    crew=#p.run.crew,cargo=p.run.cargo,wagon=p.run.wagon,food=p.run.food,recovery=r.totals.recovery_days,
    recovery_food=food,searches=searches,battles=battles,wins=wins,days_by_command=r.totals.days_by_command}
   out.rows[#out.rows+1]=row
   group.runs=group.runs+1;group.outcomes[row.outcome]=(group.outcomes[row.outcome] or 0)+1
   for _,key in ipairs({"recovery","searches","battles","wins","recovery_food","cargo"}) do group[key]=group[key]+row[key] end
   group.days=group.days+row.day
   if seed==1 and (c.id=="adaptive_2" or c.id=="solo_2") then out.samples[#out.samples+1]={rules=rules,starter=starter,policy=c.id,steps=r.steps} end
  end
  out.groups[#out.groups+1]=group
 end end end
 return out
end
if arg and arg[0] and arg[0]:match("discovery_balance.lua$") then
 local path=assert(arg[1],"Output path required");assert(not io.open(path,"rb"),"Use a new output file")
 local out=M.run(tonumber(arg[2]) or 12,arg[3]=="compare",arg[4]=="classic")
 local f=assert(io.open(path,"wb"));f:write(json.encode(out));f:close()
 for _,g in ipairs(out.groups) do print(string.format("%s %s %s deliver %d/%d rescue %d days %.1f recovery %.1f search %.1f wins %d/%d",g.rules,g.starter,g.policy,g.outcomes.delivered or 0,g.runs,g.outcomes.rescued or 0,g.days/g.runs,g.recovery/g.runs,g.searches/g.runs,g.wins,g.battles)) end
end
return M
