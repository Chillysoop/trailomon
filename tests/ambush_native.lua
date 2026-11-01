local c=require "simulation.wagon_combat"
local save=require "services.ambush_save"
local controller=require "services.ambush_controller"
local util=require "simulation.util"
local function equal(a,b)
    assert(type(a)==type(b))
    if type(a)=="table" then for k,v in pairs(a) do equal(v,b[k]) end;for k in pairs(b) do assert(a[k]~=nil) end
    else assert(a==b,tostring(a).." != "..tostring(b)) end
end
local M={}
function M.persistence()
    local namespace=sys.get_config_string("trailomon.save_namespace","")
    assert(namespace=="trailomon_automated_checks" or namespace:match("^trailomon_qa_"))
    local path=save.path();assert(path:find(namespace,1,true) and path:find("wagon_ambush_v1",1,true))
    local s=c.new();assert(save.write({battle=s,speed=1,carry=0}))
    c.start(s);c.step(s,48);assert(save.write({battle=s,speed=2,carry=0.05}))
    local recovered=assert(save.load());equal(recovered.battle,s);assert(recovered.carry==0.05 and recovered.speed==2)
    local original=util.copy(s);c.step(s,1800);c.step(recovered.battle,1800);equal(recovered.battle,s)
    assert(save.write({battle=s,speed=2,carry=0}))
    local file=assert(io.open(path,"wb"));file:write("corrupt");file:close()
    local fallback,notice=save.load();assert(fallback and notice);equal(fallback.battle,original)
    assert(save.write(fallback));os.remove(path)
    assert(save.load(),"A missing primary should recover its backup")
    os.remove(path..".backup")
end
function M.controls(self,button)
    local input=require "ui.input";local screens=require "ui.screens"
    local before=util.copy(self.snapshot);local record
    local memory={load=function() return util.copy(record) end,write=function(v) assert(save.validate(v));record=util.copy(v);return true end}
    self.redraw=function() screens.draw(self) end
    self.open_page=function(page) if self.page=="ambush" then controller.pause(self) end;self.page=page;self.redraw() end
    self.has_focus=true;self.ambush=nil;controller.open(self,memory);coroutine.yield()
    for i,b in ipairs(self.buttons) do if b.key=="ambush_rush" then self.focus=i end end
    input.handle(self,hash("confirm"),{pressed=true});coroutine.yield()
    assert(self.ambush.battle.preset=="rush")
    button(self,"ambush_move_moss").fn();coroutine.yield();assert(self.ambush.battle.preset=="custom")
    button(self,"ambush_guard").fn();coroutine.yield()
    button(self,"ambush_start").fn();coroutine.yield();assert(self.ambush.battle.phase=="fight")
    controller.update(self,0.2);coroutine.yield();assert(self.ambush.battle.tick==2)
    input.handle(self,hash("pause"),{pressed=true});coroutine.yield();assert(self.ambush.paused)
    controller.update(self,0.2);assert(self.ambush.battle.tick==2)
    button(self,"ambush_reload").fn();coroutine.yield();assert(self.ambush.paused and self.ambush.battle.tick==2)
    button(self,"ambush_speed").fn();coroutine.yield();assert(self.ambush.speed==2)
    button(self,"ambush_pause").fn();coroutine.yield();controller.update(self,0.25);coroutine.yield()
    assert(self.ambush.battle.tick==7)
    button(self,"ambush_retreat").fn();coroutine.yield();assert(self.ambush.battle.result=="retreated")
    button(self,"ambush_new").fn();coroutine.yield();assert(self.ambush.battle.phase=="setup")
    input.handle(self,hash("back"),{pressed=true});coroutine.yield();assert(self.page=="trail" and self.ambush.paused)
    equal(before,self.snapshot)
end
return M
