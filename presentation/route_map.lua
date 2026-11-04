-- Geography is presentation only: every fork comes from the real expedition.
local route=require "content.route"
local forks=require "content.forks"
local M={}
M.places={
    {id="depot",x=115,y=68,icon="collection",name="Fernwake"},
    {id="split",x=225,y=153,icon="flag",name="Split Oak"},
    {id="outpost",x=442,y=100,icon="food",name="Mossbell",note="Last shop"},
    {id="river",x=602,y=178,icon="water",name="Willowford"},
    {id="gate",x=752,y=153,icon="rest",name="Cairn Gate",note="Last shelter"},
    {id="reach",x=935,y=257,icon="cargo",name="Lantern Reach"},
}
M.branches={
    meadow={x=330,y=78,name="Meadow",icon="forage",target=2},
    woodland={x=330,y=253,name="Woodland",icon="scout",target=2},
    ridge={x=837,y=278,name="Ridge",icon="wagon",target=5},
    gorge={x=861,y=93,name="Gorge",icon="guard",target=5},
}
function M.path(target,branch)
    local a,b=M.places[target-1],M.places[target]
    if not a or not b then return {} end
    local middle=M.branches[branch]
    if middle and middle.target==target-1 then return {a,middle,b} end
    return {a,b}
end
function M.sample(points,t)
    t=math.max(0,math.min(1,t));local length=0;local lengths={}
    if t==0 or t==1 then local p=points[t==0 and 1 or #points];return {x=p.x,y=p.y} end
    for i=2,#points do
        local a,b=points[i-1],points[i]
        lengths[i]=math.sqrt((b.x-a.x)^2+(b.y-a.y)^2);length=length+lengths[i]
    end
    local distance=t*length
    for i=2,#points do
        if distance<=lengths[i] or i==#points then
            local a,b=points[i-1],points[i];local f=distance/math.max(1,lengths[i])
            return {x=a.x+(b.x-a.x)*f,y=a.y+(b.y-a.y)*f}
        end
        distance=distance-lengths[i]
    end
    return {x=points[1].x,y=points[1].y}
end
function M.branch(s,target)
    return (s.branches or {})[target==3 and "first" or "last"]
end
function M.position(s)
    if s.mode=="preparation" then return {x=M.places[1].x,y=M.places[1].y} end
    return M.sample(M.path(s.target,M.branch(s,s.target)),s.progress/math.max(1,s.distance))
end
function M.options(s)
    if s.mode~="landmark" or s.road_story then return {} end
    return forks[s.target] or {}
end
function M.reached(s,i)
    return i<s.target or (i==s.target and s.progress>=s.distance)
end
function M.name(s) return route[s.target].name end
return M
