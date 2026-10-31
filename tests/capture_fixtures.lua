local model=require "simulation.expedition"
local M={}
local function reset(self,page)
    self.snapshot=model.new(1848);assert(model.command(self.snapshot,"depart"))
    self.page=page;self.speed=1;self.focus=1;self.time=0
    self.battle_team={};self.battle_actions={};self.edit=nil;self.save_blocked=false
    self.combat_paused=true;self.combat_speed=1;self.combat_log=nil
    self.capture_actions={};self.capture_assert=nil
    self.toast="Automated fixture / isolated / no player save"
end
function M.click(self,key)
    for _,button in ipairs(self.buttons) do
        if button.key==key then assert(button.enabled,"Disabled fixture action: "..key);button.fn();return end
    end
    error("Missing fixture action: "..key)
end
function M.options(self) reset(self,"settings");self.redraw() end
function M.options_brisk(self)
    M.options(self);self.capture_actions={"travel_speed"}
    self.capture_assert=function() assert(self.snapshot.settings.travel_speed==2) end
end
function M.combat_setup(self)
    reset(self,"trail");assert(model.debug(self.snapshot,"event","scavengers"))
    assert(model.command(self.snapshot,"choice",{id="battle"}));self.redraw()
end
function M.combat_ready(self)
    M.combat_setup(self);self.capture_actions={"battler1","battler2","battle_begin"}
    self.capture_assert=function() assert(self.snapshot.run.mode=="combat" and #self.snapshot.run.battle.history==0) end
end
function M.guardian_setup(self)
    reset(self,"trail");assert(model.debug(self.snapshot,"event","territorial"))
    assert(model.command(self.snapshot,"choice",{id="battle"}));self.redraw()
end
function M.guardian_tired_result(self)
    M.guardian_setup(self)
    for _,c in ipairs(self.snapshot.run.crew) do c.stamina=16 end
    self.redraw()
    self.capture_actions={"battler1","battler2","battle_begin","combat_step","combat_step","combat_step","combat_step"}
    self.capture_assert=function()
        local s=self.snapshot.run
        assert(s.mode=="combat_result" and s.battle.outcome=="won")
        assert(s.crew[1].stamina==0 and s.crew[2].stamina==0)
    end
end
function M.legacy_guardian_setup(self)
    M.guardian_setup(self);self.snapshot.run.combat_effort=nil;self.redraw()
end
function M.guardian_warning(self)
    M.guardian_setup(self)
    self.capture_actions={"battler1","battler2","battle_begin","combat_step"}
    self.capture_assert=function() assert(self.snapshot.run.battle.intent.kind=="warning") end
end
function M.guardian_rush(self)
    M.guardian_warning(self);self.capture_actions[#self.capture_actions+1]="combat_step"
    self.capture_assert=function() assert(self.snapshot.run.battle.intent.kind=="heavy" and self.snapshot.run.battle.round==3) end
end
function M.developer(self) reset(self,"debug");self.redraw() end
function M.route_depot(self) reset(self,"trail");self.redraw() end
local function stop(self,target)
    reset(self,"trail");local s=self.snapshot.run
    s.target=target;s.distance=model.route[target].distance;s.progress=s.distance
    s.terrain=model.route[target].terrain;s.mode="landmark"
    self.redraw()
end
function M.route_oak(self) stop(self,2) end
function M.route_meadow(self)
    M.route_oak(self);self.capture_actions={"Across the meadows"}
    self.capture_assert=function() assert(self.snapshot.run.terrain=="meadow" and self.snapshot.run.target==3) end
end
function M.route_woodland(self)
    M.route_oak(self);self.capture_actions={"Through the woodland"}
    self.capture_assert=function() assert(self.snapshot.run.terrain=="woodland" and self.snapshot.run.target==3) end
end
function M.route_outpost(self) stop(self,3) end
function M.route_river(self) stop(self,4) end
function M.route_gate(self) stop(self,5) end
function M.route_ridge(self)
    M.route_gate(self);self.capture_actions={"Take the ridge road"}
    self.capture_assert=function() assert(self.snapshot.run.terrain=="ridge" and self.snapshot.run.target==6) end
end
function M.route_gorge(self)
    M.route_gate(self);self.capture_actions={"Follow the sheltered gorge"}
    self.capture_assert=function() assert(self.snapshot.run.terrain=="gorge" and self.snapshot.run.target==6) end
end
function M.route_reach(self)
    stop(self,6);model.finish(self.snapshot,"delivered","The orchard cuttings reach Lantern Reach in time. There will be new trees here next spring.")
    self.redraw()
end
function M.route_map(self) M.route_outpost(self);self.page="map";self.redraw() end
function M.route_rain(self) M.route_river(self);self.snapshot.run.weather="rain";self.redraw() end
function M.items_prep(self)
    reset(self,"trail");self.snapshot=model.new(1848);self.redraw()
end
function M.items_shop(self)
    stop(self,3);self.page="shop";self.redraw()
end
function M.items_depot(self)
    reset(self,"trail");self.snapshot=model.new(1848);self.redraw()
    self.capture_actions={"open_items"}
end
function M.items_equipped(self)
    M.items_depot(self)
    self.capture_actions={"open_items","item_padded_trace","item_padded_trace","item_release_rope","item_member2","item_release_rope"}
    self.capture_assert=function()
        local s=self.snapshot.run
        assert(s.crew[1].work_item=="padded_trace" and s.crew[2].work_item=="release_rope")
        assert(s.coins==28 and model.resources.weight(s)==138)
    end
end
function M.items_battle(self)
    reset(self,"trail");local p=self.snapshot
    p.run.mode="preparation"
    assert(model.command(p,"buy_work_item",{item="padded_trace"}))
    assert(model.command(p,"equip_work_item",{member=1,item="padded_trace"}))
    assert(model.command(p,"buy_work_item",{item="release_rope"}))
    assert(model.command(p,"equip_work_item",{member=2,item="release_rope"}))
    assert(model.command(p,"depart"));assert(model.debug(p,"event","territorial"))
    assert(model.command(p,"choice",{id="battle"}));self.redraw()
    self.capture_actions={"battler1","battler2","battle_begin","combat_step","combat_step","combat_step"}
    self.capture_assert=function() assert(p.run.battle.item_used.padded_trace and p.run.crew[1].condition==100) end
end
function M.items_locked(self)
    M.items_battle(self);self.capture_actions={};self.page="work_items";self.redraw()
    self.capture_assert=function() assert(not model.equipment.can_equip(self.snapshot.run)) end
end
function M.items_crew(self)
    M.items_battle(self);self.capture_actions={};self.page="crew";self.redraw()
    self.capture_assert=function() assert(self.snapshot.run.crew[1].work_item=="padded_trace") end
end
return M
