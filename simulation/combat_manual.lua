local resources = require "simulation.resources"
local species = require "content.species"
local rng = require "simulation.rng"
local util = require "simulation.util"
local M = {}

local function intention(s)
    local b = s.battle
    if rng.next(s.rng,"combat") < 0.55 then
        b.intent = {target="cargo", damage=b.kind=="scavengers" and 13 or 10}
    else
        b.intent = {target=b.team[rng.int(s.rng,"combat",1,#b.team)], damage=12}
    end
end
function M.start(s, kind, team)
    if kind~="scavengers" and kind~="territorial" then return false,"Unknown encounter" end
    if type(team)~="table" or #team<1 or #team>2 then return false,"Choose one or two companions" end
    local seen={}
    for _, i in ipairs(team) do
        if seen[i] or not resources.ready(s.crew[i],6) then return false,"Choose different, ready companions" end
        seen[i]=true
    end
    s.battle={kind=kind,team=util.copy(team),round=1,limit=kind=="scavengers" and 3 or 4,
        resolve=kind=="scavengers" and 65 or 75,used={},last="",intent={}}
    intention(s)
    s.mode="combat"
    return true
end
function M.intent_text(s)
    local intent=s.battle.intent
    local target=intent.target=="cargo" and "the cargo" or s.crew[intent.target].name
    return "Next: strike " .. target .. " for " .. intent.damage .. ". Guard can reduce it."
end
function M.round(s, actions)
    local b=s.battle
    if type(actions)~="table" or #actions~=#b.team then return false,"Choose one action per companion" end
    local allowed, seen, costs={}, {}, {pressure=6,guard=3,assist=12}
    for _, i in ipairs(b.team) do allowed[i]=true end
    for _, a in ipairs(actions) do
        if not allowed[a.member] or seen[a.member] or not costs[a.kind] then return false,"Invalid battle actions" end
        local c=s.crew[a.member]
        -- An exhausted member can guard weakly at zero cost so a round cannot deadlock.
        if a.kind~="guard" and not resources.ready(c,costs[a.kind]) then return false,c.name .. " needs rest" end
        if a.kind=="assist" and b.used[a.member] then return false,"Assist is once per battle" end
        seen[a.member]=true
    end
    local guard, pressure={},0
    guard.cargo=0
    for _, a in ipairs(actions) do
        local c=s.crew[a.member]
        local def=species.defs[c.species]
        local able=resources.ready(c,3)
        local awake=c.condition>0
        c.stamina=math.max(0,c.stamina-((a.kind=="guard" and not awake) and 0 or costs[a.kind]))
        if a.kind=="pressure" then pressure=pressure+def.pressure
        elseif a.kind=="guard" then
            guard[a.member]=(guard[a.member] or 0)+(able and 10 or (awake and 3 or 0))
            guard.cargo=guard.cargo+(able and 7 or (awake and 2 or 0))
        else
            b.used[a.member]=true
            local defensive=c.species=="brindlehorn" or c.species=="slatewhorl"
            pressure=pressure+(defensive and 8 or 21)
            guard.cargo=guard.cargo+(defensive and 18 or 5)
            for _, i in ipairs(b.team) do guard[i]=(guard[i] or 0)+(defensive and 12 or 4) end
        end
    end
    b.resolve=math.max(0,b.resolve-pressure)
    local damage=0
    if b.resolve>0 then
        damage=math.max(0,b.intent.damage-(guard[b.intent.target] or 0))
        if b.intent.target=="cargo" then s.cargo=math.max(0,s.cargo-damage)
        else local c=s.crew[b.intent.target]; c.condition=math.max(0,c.condition-damage) end
    end
    b.last="Resolve -" .. pressure .. ". Incoming harm " .. damage .. "."
    local all_down=true
    for _, i in ipairs(b.team) do if resources.ready(s.crew[i],1) then all_down=false end end
    local outcome
    if b.resolve<=0 or (b.kind=="scavengers" and b.round>=b.limit) then outcome="won"
    elseif all_down or b.round>=b.limit then outcome="fallback" end
    if outcome then return true,outcome end
    b.round=b.round+1
    intention(s)
    return true
end
return M
