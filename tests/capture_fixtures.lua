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
return M
