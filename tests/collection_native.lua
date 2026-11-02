local model=require "simulation.expedition"
local collection=require "simulation.collection"
local save=require "services.save"
local M={}
M.fixture=require "tests.collection_fixture"
function M.persistence()
    local current=assert(save.load())
    local p=model.new(1848,save.slot())
    for i=#p.profile.collection+1,1000 do collection.collect(p,model.species.order[(i-1)%6+1]) end
    for _,c in ipairs(p.profile.collection) do c.memories={"Met beside the old orchard and chose to travel with this wagon.","Returned safely from a difficult expedition."} end
    assert(save.write(p));local q=assert(save.load());assert(#q.profile.collection==1000 and q.profile.collection[1000].uid==1000)
    assert(model.command(q,"depart"));assert(model.debug(q,"event","scavengers"));assert(model.command(q,"choice",{id="battle"}))
    assert(model.command(q,"road_start"));assert(model.command(q,"road_step",{ticks=25}))
    assert(save.write(q));local r=assert(save.load());assert(#r.run.wagon_battle.battle.units==6)
    assert(require("tools.report.json").encode(q)==require("tools.report.json").encode(r))
    assert(save.write(current))
end
function M.controls(self,button)
    self.ambush=nil;self.snapshot=M.fixture();self.page="trail"
    self.perform=function(id,args,page) assert(model.command(self.snapshot,id,args));self.page=page or self.page;self.redraw() end
    self.open_page=function(page) self.page=page;self.redraw() end
    self.redraw();coroutine.yield()
    button(self,"open_collection").fn();coroutine.yield();assert(self.page=="collection")
    local p=self.snapshot;local stored=p.run.crew[1].uid
    assert(not button(self,"collection_select_5").enabled)
    button(self,"collection_select_"..stored).fn();coroutine.yield()
    button(self,"collection_select_5").fn();coroutine.yield()
    assert(p.run.crew[4].uid==5 and #p.run.crew==4 and save.validate(p))
    button(self,"collection_next").fn();coroutine.yield();assert(self.collection_page==2)
    button(self,"collection_depot").fn();coroutine.yield();assert(self.collection_page==1)
    button(self,"collection_back").fn();coroutine.yield()
    assert(model.command(p,"depart"));self.page="crew";self.redraw();coroutine.yield()
    button(self,"detail4").fn();coroutine.yield();assert(self.page=="companion")
    self.page="crew";self.redraw();coroutine.yield();button(self,"open_collection").fn();coroutine.yield()
    for _,b in ipairs(self.buttons) do
        if b.key:match("^collection_select_") then assert(not b.enabled) end
        local pos,size=gui.get_position(b.node),gui.get_size(b.node)
        assert(pos.x-size.x/2>=0 and pos.x+size.x/2<=1280 and pos.y-size.y/2>=0 and pos.y+size.y/2<=720,"Collection control clipped")
    end
end
return M
