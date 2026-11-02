-- Read-only battlefield presentation. Never advances clocks or consumes RNG.
local M={}
local crew={{620,465},{660,290},{395,465},{435,290}}
function M.point(u)
    if u.id=="wagon" then return 165,420 end
    if u.side=="foe" then if u.id=="raider" then return 885,465 else return 1090,290 end end
    local p=crew[u.position];return p[1],p[2]
end
function M.short(text,n)
    -- Respect UTF-8 boundaries in player names.
    local chars={};for char in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do chars[#chars+1]=char end
    if #chars<=n then return text end
    return table.concat(chars,"",1,n-3).."..."
end
function M.feedback(s,id)
    local result={}
    for i=#s.events,1,-1 do
        local e=s.events[i];if s.tick-e.tick>7 then break end
        if e.source==id and e.kind=="cast" and not result.cast then result.cast=e end
        if e.target==id and not result.hit and (e.kind=="attack" or e.kind=="skill" or e.kind=="follow") then result.hit=e end
        if not result.support and ((e.target==id and (e.kind=="shield" or e.kind=="supply")) or (e.source==id and e.kind=="absorbed")) then result.support=e end
    end
    return result
end
-- Sprite-only, read-only accents. Positive Y is upward in Defold.
-- Saved combat time makes pause/reload stable; no cosmetic RNG or outcome changes.
function M.motion(s,u,carry,enabled)
    if not enabled or s.phase~="fight" or u.hp<=0 then return 0,0 end
    local dx,dy=0,0
    for i=#s.events,1,-1 do
        local e=s.events[i];local age=(s.tick-e.tick)*0.1+(carry or 0)
        if age>0.4 then break end
        if e.source==u.id then
            if e.kind=="cast" then
                dy=math.max(dy,6*math.sin(math.pi*math.min(1,age/0.4)))
            elseif e.kind=="attack" or e.kind=="follow" then
                dx=math.max(dx,8*math.sin(math.pi*math.min(1,age/0.3)))
            end
        end
    end
    return dx*(u.side=="crew" and 1 or -1),dy
end
return M
