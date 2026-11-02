-- Compare rendered explanations with the journey's active recovery/combat rules.
local M={}
function M.controls(self,button)
    local model=require "simulation.expedition"
    local screens=require "ui.screens"
    local widgets=require "ui.widgets"
    local original=widgets.text
    self.perform=function(id,args,page)
        assert(model.command(self.snapshot,id,args));self.page=page or self.page;self.redraw()
    end
    for _,legacy in ipairs({false,true}) do
        self.snapshot=model.new(1848,"discovery")
        if legacy then self.snapshot.run.recovery_rules=nil;self.snapshot.run.road_combat_rules=nil end
        assert(model.command(self.snapshot,"depart"))
        self.snapshot.run.crew[1].condition=10
        local text={}
        widgets.text=function(s,x,y,value,...) text[tostring(value)]=true;return original(s,x,y,value,...) end
        self.page="crew";screens.draw(self);widgets.text=original;coroutine.yield()
        local _,camp=require("simulation.recovery").values(self.snapshot.run)
        assert(text["1 day + meals + 1 medicine / +35 Condition; fed camp +"..camp.." to crew."])
        assert(gui.get_text(button(self,"treat1").label)=="Treat & rest")
        button(self,"treat1").fn();coroutine.yield()
        assert(self.snapshot.run.crew[1].condition==10+35+camp)
        assert(self.snapshot.run.day==2 and self.snapshot.run.medicine==1)
        text={}
        widgets.text=function(s,x,y,value,...) text[tostring(value)]=true;return original(s,x,y,value,...) end
        self.page="work_items";screens.draw(self);widgets.text=original;coroutine.yield()
        for _,item in pairs(model.equipment.defs) do
            assert(text[legacy and item.battle or item.wagon])
            assert(not text[legacy and item.wagon or item.battle])
        end
    end
end
return M
