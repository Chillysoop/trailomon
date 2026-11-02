-- Read the actual GUI and exercise navigation without spending expedition resources.
local M={}
local function equal(a,b)
    if type(a)~="table" or type(b)~="table" then return a==b end
    for k,v in pairs(a) do if not equal(v,b[k]) then return false end end
    for k in pairs(b) do if a[k]==nil then return false end end
    return true
end
function M.controls(self,button)
    local model=require "simulation.expedition"
    local util=require "simulation.util"
    local w=require "ui.widgets"
    local kits=require "content.ambush"
    self.snapshot=model.new(1848,"discovery");assert(model.command(self.snapshot,"depart"))
    self.perform=function(id,args,page)
        assert(model.command(self.snapshot,id,args));self.page=page or self.page;self.redraw()
    end
    self.open_page=function(page) self.page=page;self.redraw() end
    self.page="camp";self.redraw();coroutine.yield()
    local before=util.copy(self.snapshot.run)
    button(self,"camp_crew").fn();coroutine.yield()
    assert(self.page=="crew" and equal(before,self.snapshot.run),"Opening crew care must be free")
    for _,legacy in ipairs({false,true}) do
        self.snapshot.run.road_combat_rules="wagon-road-v1"
        if legacy then self.snapshot.run.road_combat_rules=nil end
        for _,id in ipairs(model.species.order) do
            self.snapshot.run.crew[1]=require("simulation.progression").companion(id)
            self.page="crew";self.redraw();coroutine.yield()
            button(self,"detail1").fn();coroutine.yield()
            assert(self.page=="companion")
            local text={};local original=w.text
            w.text=function(s,x,y,value,...) text[tostring(value)]=true;return original(s,x,y,value,...) end
            self.redraw();w.text=original;coroutine.yield()
            local kit=kits.kits[kits.by_species[id]]
            assert(text[model.species.defs[id].ability],"Travel ability missing")
            if legacy then
                assert(text["Encounter / "..model.species.defs[id].assist] and not text[kit.active],"Legacy journey shows wrong combat rules")
            else
                assert(text[kit.active] and text[kit.passive] and text["Repeats at "..kit.cost.." Focus"],"Combat kit must match the playable creature")
            end
        end
    end
    self.snapshot=model.new(1848);assert(model.command(self.snapshot,"depart"))
    self.page="trail";self.redraw();coroutine.yield()
    before=util.copy(self.snapshot.run)
    assert(gui.get_text(button(self,"travel_speed").label)=="Playback: calm")
    button(self,"travel_speed").fn();coroutine.yield()
    assert(gui.get_text(button(self,"travel_speed").label)=="Playback: brisk")
    assert(equal(before,self.snapshot.run),"Playback must not change travel pace or resources")
end
return M
