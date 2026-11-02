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
return M
