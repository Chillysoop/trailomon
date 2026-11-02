local model=require "simulation.expedition"
local save=require "services.save"
local util=require "simulation.util"
local recovery=require "simulation.recovery"
local function cmd(p,id,arg) local ok,why=model.command(p,id,arg);assert(ok,why);local valid,reason=save.validate(p);assert(valid,reason) end
local function wounded(old)
 local p=model.new(1,"discovery");if old then p.run.recovery_rules=nil end
 cmd(p,"depart");local s=p.run;s.crew[1].stamina=10;s.crew[1].condition=12;s.wagon=25
 return p
end
return function(test,equal)
 test("new camp recovery pays one day and meals; old saves retain 25 and 8",function()
  for _,old in ipairs({false,true}) do
   local p=wounded(old);local energy,condition=recovery.values(p.run);local before=util.copy(p)
   cmd(p,"rest");assert(p.run.day==2 and p.run.food==before.run.food-model.resources.daily_food(before.run))
   assert(p.run.crew[1].stamina==10+energy and p.run.crew[1].condition==12+condition)
   local replay=util.copy(before);cmd(replay,"rest");equal(p,replay)
  end
 end)
 test("a new repair day also rests the crew without extra supply or time",function()
  for _,old in ipairs({false,true}) do
   local p=wounded(old);cmd(p,"repair");assert(p.run.day==2 and p.run.food==87 and p.run.repairs==2 and p.run.wagon==55)
   assert(p.run.crew[1].condition==(old and 12 or 32))
   assert(p.run.crew[1].stamina==(old and 17 or 50))
  end
 end)
 test("medicine keeps its bonus and includes exactly one camp recovery",function()
  local p=wounded();cmd(p,"treat",{member=1})
  assert(p.run.day==2 and p.run.medicine==1 and p.run.food==87)
  assert(p.run.crew[1].condition==67 and p.run.crew[1].stamina==50)
  p.run.crew[1].condition=100;local before=util.copy(p);assert(not model.command(p,"treat",{member=1}));equal(p,before)
 end)
 test("camp never grants foodless healing and still respects closure and caps",function()
  local p=wounded();p.run.food=0;cmd(p,"rest");assert(p.run.crew[1].condition==6 and p.run.crew[1].stamina==10)
  p=wounded();p.run.crew[1].condition=97;p.run.crew[1].stamina=96;cmd(p,"rest")
  assert(p.run.crew[1].condition==100 and p.run.crew[1].stamina==100)
  p=wounded();p.run.day=31;cmd(p,"repair");assert(p.run.outcome=="rescued" and p.run.day==32 and p.run.wagon==25)
 end)
 test("recovery rule survives checkpoint and unknown versions are rejected",function()
  local p=wounded();cmd(p,"repair");local loaded=util.copy(p);assert(save.validate(loaded));cmd(p,"rest");cmd(loaded,"rest");equal(p,loaded)
  p.run.recovery_rules="future";assert(not save.validate(p))
 end)
 test("solo road defeat can recover with the new camp without free resurrection",function()
  local p=model.new(1,"discovery");cmd(p,"starter",{species="reedskipper"});cmd(p,"depart")
  assert(model.debug(p,"event","scavengers"));cmd(p,"choice",{id="battle"});cmd(p,"road_start")
  for _=1,100 do if p.run.wagon_battle.battle.phase=="result" then break end;cmd(p,"road_step",{ticks=20}) end
  assert(p.run.wagon_battle.settled);cmd(p,"road_continue")
  local before=util.copy(p);assert(p.run.crew[1].condition<50)
  cmd(p,"rest");assert(p.run.day==before.run.day+1 and p.run.crew[1].condition==math.min(100,before.run.crew[1].condition+20))
  assert(p.run.wagon==before.run.wagon and p.run.cargo==before.run.cargo)
 end)
end
