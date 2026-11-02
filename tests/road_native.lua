local model=require "simulation.expedition"
local save=require "services.save"
local util=require "simulation.util"
local M={}
local function equal(a,b)
    assert(type(a)==type(b))
    if type(a)=="table" then for k,v in pairs(a) do equal(v,b[k]) end;for k in pairs(b) do assert(a[k]~=nil) end
    else assert(a==b,tostring(a).." != "..tostring(b)) end
end
function M.persistence()
    local namespace=sys.get_config_string("trailomon.save_namespace","")
    assert(namespace=="trailomon_automated_checks" or namespace:match("^trailomon_qa_"))
    local current=assert(save.load())
    for _,mode in ipairs({"discovery","classic"}) do
        current=assert(save.select(current,mode))
        local p=model.new(31,mode);assert(model.command(p,"depart"))
        assert(model.debug(p,"event","scavengers"));assert(model.command(p,"choice",{id="battle"}))
        assert(save.write(p));equal(save.load(),p)
        assert(model.command(p,"road_start"))
        while p.run.wagon_battle.battle.phase=="fight" do
            p.run.wagon_battle.speed=2;p.run.wagon_battle.carry=0.05
            assert(save.write(p));local restored=assert(save.load());equal(restored,p)
            assert(model.command(p,"road_step",{ticks=10}));assert(model.command(restored,"road_step",{ticks=10}));equal(p,restored)
        end
        assert(save.write(p));equal(save.load(),p)
        local original=util.copy(p);assert(save.write(p))
        local primary=save.paths();local f=assert(io.open(primary,"wb"));f:write("corrupt");f:close()
        local recovered,notice=save.load();assert(notice);equal(recovered,original)
        assert(model.command(recovered,"road_continue"));assert(save.write(recovered));equal(save.load(),recovered)
        current=recovered
    end
end
function M.controls(self,button)
    local controller=require "services.ambush_controller"
    local screens=require "ui.screens"
    local scene=require "presentation.scene"
    self.ambush=nil;self.snapshot=model.new(73);assert(model.command(self.snapshot,"depart"))
    assert(model.debug(self.snapshot,"event","scavengers"));assert(model.command(self.snapshot,"choice",{id="battle"}))
    self.road_writer=function(candidate) assert(save.validate(candidate));return true end
    self.page="trail";screens.draw(self);coroutine.yield()
    assert(self.page=="ambush" and self.ambush.road)
    button(self,"ambush_move_moss").fn();coroutine.yield()
    button(self,"ambush_back").fn();coroutine.yield();assert(self.snapshot.run.mode=="event")
    assert(model.command(self.snapshot,"choice",{id="battle"}));self.page="trail";screens.draw(self);coroutine.yield()
    button(self,"ambush_start").fn();coroutine.yield()
    for _=1,18 do controller.update(self,0.1);coroutine.yield() end
    scene.update(self,0,false,true)
    button(self,"ambush_pause").fn();coroutine.yield()
    button(self,"ambush_reload").fn();coroutine.yield()
    assert(self.ambush.paused and self.snapshot.run.crew[1].stamina==94)
    button(self,"ambush_speed").fn();coroutine.yield()
    button(self,"ambush_pause").fn();coroutine.yield()
    for _=1,360 do controller.update(self,0.25);coroutine.yield();if self.ambush.battle.phase=="result" then break end end
    coroutine.yield();assert(self.snapshot.run.wagon_battle.settled)
    button(self,"ambush_back").fn();coroutine.yield()
    assert(self.page=="trail" and self.snapshot.run.mode=="stopped" and not self.ambush)
end
return M
