local M={}
function M.new() return {elapsed=0} end
function M.reset(clock) clock.elapsed=0 end
function M.tick(clock,dt,active,seconds_per_day)
    if not active then clock.elapsed=0; return false end
    -- A suspended window must never catch up several days on focus return.
    clock.elapsed=clock.elapsed+math.min(math.max(dt,0),0.25)
    if clock.elapsed>=seconds_per_day then clock.elapsed=0; return true end
    return false
end
return M
