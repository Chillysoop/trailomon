local M={}
function M.controls(self,button)
    local model=require "simulation.expedition"
    local input=require "ui.input"
    local motion=require "presentation.journey_motion"
    local map=require "presentation.route_map"
    self.snapshot=require("tests.collection_fixture")();self.page="trail";self.ambush=nil
    self.map_detail=nil;self.journey_motion=nil;self.journey_details=nil
    self.perform=function(id,args,page) assert(model.command(self.snapshot,id,args));self.page=page or self.page;self.redraw() end
    self.open_page=function(page) self.page=page;self.redraw() end
    self.redraw();coroutine.yield()
    local food=self.snapshot.run.food
    button(self,"buy_food").fn();coroutine.yield();assert(self.snapshot.run.food==food+10)
    button(self,"sell_food").fn();coroutine.yield();assert(self.snapshot.run.food==food)
    button(self,"BEGIN THE JOURNEY").fn();coroutine.yield()
    assert(self.map_actor and self.snapshot.run.mode=="stopped")
    local before=require("simulation.util").copy(self.snapshot)
    button(self,"map_reach").fn();coroutine.yield();assert(self.map_detail==6)
    button(self,"map_close").fn();coroutine.yield()
    assert(require("tools.report.json").encode(before)==require("tools.report.json").encode(self.snapshot))
    for _,target in ipairs({2,5}) do
        for _,path in ipairs(require("content.forks")[target]) do
            local s=self.snapshot.run;s.target=target;s.mode="landmark";s.progress=s.distance
            self.page="trail";self.redraw();coroutine.yield()
            for i,b in ipairs(self.buttons) do if b.key==path.label then self.focus=i end end
            input.handle(self,hash("confirm"),{pressed=true});coroutine.yield()
            assert(s.terrain==path.id and s.distance==path.distance and s.mode=="traveling")
            s.progress=s.distance/2;self.redraw();coroutine.yield()
            local q=map.position(s);local pos=gui.get_position(self.map_actor.node)
            assert(math.abs(pos.x-(self.map_actor.x+q.x*self.map_actor.sx))<.01)
        end
    end
    self.snapshot=model.new(1848);assert(model.command(self.snapshot,"depart"))
    self.snapshot.run.progress=12;assert(model.debug(self.snapshot,"event","scavengers"))
    motion.begin(self,{target=2,progress=3},"step");self.redraw();coroutine.yield()
    for _,b in ipairs(self.buttons) do assert(b.key~="event_battle") end
    self.has_focus=true
    for _=1,25 do motion.update(self,.1);coroutine.yield() end
    assert(not self.journey_motion and button(self,"event_battle").enabled)
    button(self,"event_details").fn();coroutine.yield()
    button(self,"event_details_back").fn();coroutine.yield()
    self.road_writer=function(p) assert(require("services.save").validate(p));return true end
    button(self,"event_battle").fn();coroutine.yield()
    assert(self.page=="ambush" and self.ambush.road)
    button(self,"ambush_back").fn();coroutine.yield()
    assert(self.page=="trail" and self.snapshot.run.mode=="event" and self.map_actor)
    button(self,"event_withdraw").fn();coroutine.yield()
    assert(self.snapshot.run.mode=="stopped")
end
return M
