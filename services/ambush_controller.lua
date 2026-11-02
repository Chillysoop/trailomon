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
    if self.ambush and (self.ambush.practice or self.ambush.road) then M.pause(self);self.ambush=nil end
    if not self.ambush then
        storage=storage or persistence
        local record,notice=storage.load()
        self.ambush={battle=record and record.battle or combat.new(),speed=record and record.speed or 1,
            carry=record and record.carry or 0,paused=true,storage=storage,notice=notice}
    end
    self.open_page("ambush")
end
function M.open_road(self,writer)
    local util=require "simulation.util"
    local road=require "simulation.wagon_road"
    if self.save_blocked or not road.active(self.snapshot.run) then return false end
    local journey=self.snapshot.run.id
    local record=util.copy(self.snapshot.run.wagon_battle)
    local storage={load=function() return util.copy(self.snapshot.run.wagon_battle) end}
    storage.write=function(value)
        if self.save_blocked or self.snapshot.run.id~=journey then return false,"Journey changed" end
        local candidate,why=road.commit(self.snapshot,value)
        if not candidate then return false,why end
        local ok,err=(writer or require("services.save").write)(candidate)
        if not ok then return false,err end
        self.snapshot=candidate
        if candidate.run.mode=="result" then self.page="trail" end
        return true
    end
    self.ambush={battle=record.battle,speed=record.speed,carry=record.carry,paused=true,storage=storage,road=true,writer=writer}
    self.page="ambush";self.redraw();return true
end
function M.road_exit(self)
    local a=self.ambush
    if not a or not a.road or not checkpoint(self) then return false end
    local candidate=require("simulation.util").copy(self.snapshot)
    local action=candidate.run.wagon_battle.settled and "road_continue" or "battle_back"
    local ok,why=require("simulation.expedition").command(candidate,action)
    if ok then ok,why=(a.writer or require("services.save").write)(candidate) end
    if not ok then a.error=why;a.paused=true;self.redraw();return false end
    self.snapshot=candidate;self.ambush=nil;self.page="trail";self.redraw();return true
end
function M.open_practice(self,writer)
    local practice=require "simulation.wagon_practice"
    local util=require "simulation.util"
    if self.save_blocked then return false end
    M.pause(self)
    local record,why=practice.record(self.snapshot.run)
    if not record then self.toast=why;self.redraw();return false end
    local journey=self.snapshot.run.id
    local storage={load=function() return util.copy(self.snapshot.run.wagon_practice) end}
    storage.write=function(value)
        if self.save_blocked or self.snapshot.run.id~=journey then return false,"Journey changed" end
        local candidate,reason=practice.commit(self.snapshot,value)
        if not candidate then return false,reason end
        local ok,err=(writer or require("services.save").write)(candidate)
        if not ok then return false,err end
        self.snapshot=candidate;return true
    end
    self.ambush={battle=record.battle,speed=record.speed,carry=record.carry,paused=true,storage=storage,practice=true}
    if record.battle.phase=="setup" then local ready,message=practice.ready(self.snapshot.run,record.battle);if not ready then self.ambush.notice=message end end
    checkpoint(self);self.open_page("ambush");return true
end
function M.command(self,action,arg)
    local a=self.ambush;if not a then return false end
    if action=="new" then
        if a.practice or a.road then return false end
        a.battle=combat.new(arg or "guard");a.carry=0;a.paused=true;a.notice=nil
    elseif action=="start" then
        if a.road then
            local ok,why=require("simulation.wagon_road").ready(self.snapshot.run,a.battle)
            if not ok then a.notice=why;self.redraw();return false end
        end
        if a.practice then
            local ok,why=require("simulation.wagon_practice").ready(self.snapshot.run,a.battle)
            if not ok then a.notice=why;self.redraw();return false end
        end
        if not combat.start(a.battle) then return false end;a.paused=false
    elseif action=="replace" then
        if a.practice or a.road or not combat.replace(a.battle,arg.id,arg.replacement) then return false end
    elseif action=="equip" then
        if (a.practice or a.road) and arg.item~="" and not (self.snapshot.run.work_items or {})[arg.item] then return false end
        if not combat.equip(a.battle,arg.id,arg.item) then return false end
    elseif action=="supply" then
        if not a.paused or not combat.supply(a.battle,arg) then return false end
    elseif action=="move" then if not combat.move(a.battle,arg.id,arg.position) then return false end
    elseif action=="pause" then
        if a.battle.phase~="fight" then return false end
        a.paused=not a.paused
    elseif action=="speed" then a.speed=a.speed==1 and 2 or 1
    elseif action=="retreat" then
        if a.road and a.battle.phase=="setup" then combat.start(a.battle) end
        if not combat.retreat(a.battle) then return false end;a.paused=true
    elseif action=="reload" then
        local record,notice=a.storage.load()
        if not record then a.notice=notice or "No ambush checkpoint";self.redraw();return false end
        a.battle=record.battle;a.speed=record.speed;a.carry=record.carry;a.paused=true;a.notice=notice or "Ambush reloaded / paused";a.error=nil
        self.redraw();return true
    else return false end
    checkpoint(self);self.redraw();return true
end
function M.pause(self)
    if self.ambush then
        self.ambush.paused=true
        if not self.ambush.road or require("simulation.wagon_road").active(self.snapshot.run) then checkpoint(self) end
        self.redraw()
    end
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
