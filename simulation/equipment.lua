local items=require "content.work_items"
local M={defs=items.defs,order=items.order}
function M.has(c,id) return c and c.work_item==id end
function M.weight(s)
    local weight=0
    for id,owned in pairs(s.work_items or {}) do
        if owned and items.defs[id] then weight=weight+items.defs[id].weight end
    end
    return weight
end
function M.wearer(s,id,team)
    if team then
        for _,i in ipairs(team) do if M.has(s.crew[i],id) then return s.crew[i],i end end
    else
        for i,c in ipairs(s.crew) do if M.has(c,id) then return c,i end end
    end
end
function M.can_equip(s) return s.mode=="preparation" or s.mode=="stopped" or s.mode=="landmark" end
function M.shop(s) return s.mode=="preparation" or (s.mode=="landmark" and s.target==3) end
function M.label(c) return c and items.defs[c.work_item] and items.defs[c.work_item].name or "No work item" end
function M.equip(s,member,id)
    if not M.can_equip(s) then return false,"Change work items while stopped, before an encounter" end
    local c=s.crew[member]
    if not c then return false,"Choose a companion first" end
    if id~=nil and (not items.defs[id] or not (s.work_items or {})[id]) then return false,"Buy this item at Fernwake or Mossbell first" end
    if id then
        for _,other in ipairs(s.crew) do if other.work_item==id then other.work_item=nil end end
    end
    c.work_item=id
    return true
end
function M.retreat_loss(s)
    -- Before choosing a team the whole traveling crew can secure a withdrawal.
    -- Once combat starts only a participating wearer supplies the benefit.
    return M.wearer(s,"release_rope",s.battle and s.battle.team) and 4 or 8
end
return M
