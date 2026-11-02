local model=require "simulation.expedition"
local save=require "services.save"
local json=require "tools.report.json"
local M={}
function M.persistence()
 local namespace=sys.get_config_string("trailomon.save_namespace","")
 assert(namespace=="trailomon_automated_checks" or namespace:match("^trailomon_qa_"))
 local current=assert(save.load())
 for _,mode in ipairs({"discovery","classic"}) do
  current=assert(save.select(current,mode))
  for _,legacy in ipairs({false,true}) do
   local p=model.new(1,mode);if legacy then p.run.recovery_rules=nil end
   assert(model.command(p,"depart"));p.run.crew[1].condition=12;p.run.crew[1].stamina=10;p.run.wagon=25
   assert(save.write(p));local loaded=assert(save.load())
   assert(loaded.run.recovery_rules==p.run.recovery_rules)
   assert(model.command(p,"repair"));assert(model.command(loaded,"repair"));assert(json.encode(p)==json.encode(loaded))
   assert(save.write(loaded));loaded=assert(save.load())
   assert(model.command(p,"rest"));assert(model.command(loaded,"rest"));assert(json.encode(p)==json.encode(loaded))
   assert(loaded.run.crew[1].condition==(legacy and 20 or 52));current=loaded
  end
 end
end
return M
