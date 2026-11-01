local combat=require "simulation.wagon_combat"
local persistence=require "services.ambush_save"
local M={}
local function checkpoint(self)
    local a=self.ambush
    local ok,why=a.storage.write({battle=a.battle,speed=a.speed,carry=a.carry})
    a.error=not ok and why or nil
    if not ok then a.paused=true end
    return ok
end
function M.open(self,storage)
    if not self.ambush then
        storage=storage or persistence
        local record,notice=storage.load()
        self.ambush={battle=record and record.battle or combat.new(),speed=record and record.speed or 1,
            carry=record and record.carry or 0,paused=true,storage=storage,notice=notice}
    end
    self.open_page("ambush")
end
function M.command(self,action,arg)
    local a=self.ambush;if not a then return false end
    if action=="new" then a.battle=combat.new(arg or "guard");a.carry=0;a.paused=true;a.notice=nil
    elseif action=="start" then if not combat.start(a.battle) then return false end;a.paused=false
    elseif action=="move" then if not combat.move(a.battle,arg.id,arg.position) then return false end
    elseif action=="pause" then
        if a.battle.phase~="fight" then return false end
        a.paused=not a.paused
    elseif action=="speed" then a.speed=a.speed==1 and 2 or 1
    elseif action=="retreat" then if not combat.retreat(a.battle) then return false end;a.paused=true
    elseif action=="reload" then
        local record,notice=a.storage.load()
        if not record then a.notice=notice or "No ambush checkpoint";self.redraw();return false end
        a.battle=record.battle;a.speed=record.speed;a.carry=record.carry;a.paused=true;a.notice=notice or "Ambush reloaded / paused";a.error=nil
        self.redraw();return true
    else return false end
    checkpoint(self);self.redraw();return true
end
function M.pause(self)
    if self.ambush then self.ambush.paused=true;checkpoint(self);self.redraw() end
end
function M.update(self,dt)
    local a=self.ambush
    if not a or self.page~="ambush" or a.paused or a.error or not self.has_focus or a.battle.phase~="fight" then return end
    -- Bound a stalled renderer's catch-up. No time accumulates while paused.
    a.carry=a.carry+math.min(math.max(dt,0),0.25)*a.speed
    local steps=math.floor((a.carry+1e-9)/combat.TICK)
    if steps==0 then return end
    a.carry=math.max(0,a.carry-steps*combat.TICK)
    local before=math.floor(a.battle.tick/10);combat.step(a.battle,steps)
    if a.battle.phase=="result" then a.paused=true end
    if math.floor(a.battle.tick/10)~=before or a.paused then checkpoint(self) end
    self.redraw()
end
return M
