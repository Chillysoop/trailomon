-- A saved day resolves once, then its wagon crosses the map before the stop opens.
-- No timers, positions or cosmetic state are written into a player save.
local map=require "presentation.route_map"
local M={}
function M.begin(self,before,id)
    local s=self.snapshot.run
    if id~="step" or not self.snapshot.settings.motion or before.target~=s.target or s.progress<=before.progress then return end
    self.journey_motion={target=s.target,branch=map.branch(s,s.target),distance=s.distance,
        from=before.progress,to=s.progress,elapsed=0,duration=(self.snapshot.settings.travel_speed or 1)==1 and 2.4 or 0.85}
end
function M.position(self)
    local m=self.journey_motion
    if not m then return map.position(self.snapshot.run) end
    local f=math.max(0,math.min(1,m.elapsed/m.duration))
    return map.sample(map.path(m.target,m.branch),(m.from+(m.to-m.from)*f)/math.max(1,m.distance))
end
function M.update(self,dt)
    local m=self.journey_motion
    if not m then return end
    if not self.snapshot.settings.motion then self.journey_motion=nil;self.redraw();return end
    if self.has_focus==false or self.page~="trail" or self.save_error then return end
    m.elapsed=m.elapsed+math.min(math.max(dt,0),0.1)
    if m.elapsed>=m.duration then self.journey_motion=nil;self.redraw() end
end
function M.cancel(self) self.journey_motion=nil end
return M
