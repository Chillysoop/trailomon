local resources=require "simulation.resources"
local species=require "content.species"
local rng=require "simulation.rng"
local util=require "simulation.util"
local manual=require "simulation.combat_manual"
local M={RULES="automatic-v1", GUARDIAN_PATTERN="guardian-shove-v1", ORDINARY_COST=4, ABILITY_COST=8}

function M.pattern_intent(b)
    local stages={{"rush","cargo",14},{"warning",b.team[1],0},{"heavy",b.team[1],20},{"heavy","cargo",20}}
    local stage=stages[b.round]
    if not stage then return nil end
    return {kind=stage[1],target=stage[2],damage=stage[3]}
end
function M.setup_text(s)
    if s.pending and s.pending.pattern==M.GUARDIAN_PATTERN then
        return "Approach presses; wagon covers. Pattern: cargo shove 14 > approach warning 0 > heavy approach 20 > heavy cargo 20. Selection order sets positions."
    end
    return "Approach presses; wagon covers cargo and its partner. Rushes target cargo or the approach; every second rush is heavy. Selection order sets positions."
end

function M.automatic(b) return b and b.rules==M.RULES end
function M.soft_ground(s) return s.terrain~="ridge" and s.terrain~="gorge" end
function M.withdraw_text(kind)
    return kind=="scavengers" and "Leave up to 8 provisions and 8 cargo integrity." or "Take a one-day detour, including meals and weather."
end
function M.ability_text(s,id)
    local texts={
        brindlehorn="First unblocked rush at cargo or partner: brace for 14 cover.",
        reedskipper="First unblocked rush: sweep removes 10 harm and adds 4 pressure.",
        loamling=M.soft_ground(s) and "First unblocked rush: soft ground gives everyone 8 cover." or "First unblocked rush: hard rock gives everyone only 4 cover.",
        bellmoth=s.weather=="rain" and "First unblocked heavy rush: rain weakens shimmer to 8 cover." or "First unblocked heavy rush: shimmer removes 16 harm.",
        cindercoil="When partner cover helps stop a hit fully: add 20 pressure.",
        slatewhorl="By the wagon only: first unblocked cargo rush gains 18 cover.",
    }
    return texts[id]
end
function M.ordinary(s,i,position)
    local pressure=species.defs[s.crew[i].species].pressure
    return position==1 and pressure or math.floor(pressure/2), position==2 and 6 or 0
end
local function intention(s)
    local b=s.battle;local heavy=b.round%2==0
    if b.pattern==M.GUARDIAN_PATTERN then b.intent=M.pattern_intent(b);return end
    b.intent={kind=heavy and "heavy" or "rush",target=rng.next(s.rng,"combat")<0.55 and "cargo" or b.team[1],
        damage=(b.kind=="scavengers" and 12 or 14)+(heavy and 6 or 0)}
end
function M.start(s,kind,team,pattern)
    if kind~="scavengers" and kind~="territorial" then return false,"Unknown encounter" end
    if pattern~=nil and (pattern~=M.GUARDIAN_PATTERN or kind~="territorial") then return false,"Unknown encounter pattern" end
    if type(team)~="table" or #team<1 or #team>2 then return false,"Choose one or two companions" end
    local seen={}
    for _,i in ipairs(team) do
        if type(i)~="number" or i~=math.floor(i) or seen[i] or not resources.ready(s.crew[i],4) then return false,"Choose different companions with at least 4 energy" end
        seen[i]=true
    end
    local initial={food=s.food,cargo=s.cargo,day=s.day,crew={}}
    for _,i in ipairs(team) do initial.crew[i]={stamina=s.crew[i].stamina,condition=s.crew[i].condition} end
    s.battle={rules=M.RULES,pattern=pattern,kind=kind,team=util.copy(team),round=1,limit=kind=="scavengers" and 3 or 4,
        resolve=kind=="scavengers" and 65 or 75,used={},last="",history={},initial=initial}
    intention(s);s.mode="combat"
    return true
end
function M.intent_text(s)
    local b=s.battle
    if not M.automatic(b) then return manual.intent_text(s) end
    if b.intent.kind=="warning" then return "Approach warning / no harm now / heavy approach rush next: 20 before cover" end
    local target=b.intent.target=="cargo" and "cargo" or s.crew[b.intent.target].name.." at the approach"
    local title=b.pattern==M.GUARDIAN_PATTERN and b.round==1 and "Cargo shove" or (b.intent.kind=="heavy" and "Heavy rush" or "Rush")
    return title.." toward "..target.." / "..b.intent.damage.." harm before cover"
end
function M.round(s,actions)
    if M.automatic(s.battle) then return false,"Companions act automatically; advance an exchange" end
    return manual.round(s,actions)
end
function M.step(s)
    local b=s.battle
    if not M.automatic(b) or b.outcome then return false,"No automatic exchange is pending" end
    local target=b.intent.target
    local guard={cargo=0};local contribution={};local pressure=0;local notes={};local abilities={}
    local function status(i,code,text) abilities[i]={code=code,text=text} end
    local function unavailable(i)
        local c=s.crew[i]
        if b.used[i] then status(i,"spent","Spent this encounter")
        elseif b.intent.kind=="warning" then status(i,"warning","Waits: warning only, no incoming hit")
        elseif c.condition<=0 then status(i,"condition","Cannot act: needs care")
        elseif not resources.ready(c,8) then status(i,"energy","Needs 12 energy before exchange")
        elseif b.resolve<=pressure then status(i,"repelled","Not needed: threat repelled")
        else return false end
        return true
    end
    local function cover(i,who,value)
        guard[who]=(guard[who] or 0)+value
        if who==target then contribution[i]=(contribution[i] or 0)+value end
    end
    local function all_cover(i,value)
        cover(i,"cargo",value)
        for _,j in ipairs(b.team) do cover(i,j,value) end
    end
    local function remaining() return math.max(0,b.intent.damage-(guard[target] or 0)) end
    -- Ordinary actions are simultaneous. Defense resolves in position order,
    -- then one follow-up, resolve, and incoming harm. Triggers never recurse.
    for position,i in ipairs(b.team) do
        local c=s.crew[i];local p,g=M.ordinary(s,i,position)
        if resources.ready(c,4) then
            c.stamina=c.stamina-4;pressure=pressure+p
            cover(i,"cargo",g);cover(i,b.team[1],g)
            notes[#notes+1]=c.name..": "..p.." pressure"..(g>0 and ", 6 cover" or "").."."
        else
            if c.condition>0 then cover(i,position==1 and i or "cargo",1) end
            notes[#notes+1]=c.name..": exhausted; "..(c.condition>0 and "1 cover, no pressure." or "cannot act.")
        end
    end
    for position,i in ipairs(b.team) do
        local c=s.crew[i];local id=c.species;local triggered=false
        if id~="cindercoil" and not unavailable(i) then
            if id=="slatewhorl" and position~=2 then status(i,"position","Needs the wagon position")
            elseif id=="brindlehorn" and target==i then status(i,"target","Needs a rush at cargo or partner")
            elseif id=="slatewhorl" and target~="cargo" then status(i,"target","Needs a rush at cargo")
            elseif id=="bellmoth" and b.intent.kind~="heavy" then status(i,"heavy","Waits for a heavy rush")
            elseif remaining()==0 then status(i,"covered","Not needed: hit already covered")
            else
                if id=="brindlehorn" and target~=i then cover(i,target,14);triggered=true
                elseif id=="reedskipper" then cover(i,target,10);pressure=pressure+4;triggered=true
                elseif id=="loamling" then all_cover(i,M.soft_ground(s) and 8 or 4);triggered=true
                elseif id=="bellmoth" and b.intent.kind=="heavy" then cover(i,target,s.weather=="rain" and 8 or 16);triggered=true
                elseif id=="slatewhorl" and position==2 and target=="cargo" then cover(i,target,18);triggered=true end
                if triggered then
                    b.used[i]=true;c.stamina=c.stamina-8
                    status(i,"trigger",id=="bellmoth" and "Triggers: heavy rush" or (target=="cargo" and "Triggers: rush at cargo" or "Triggers: unblocked rush"))
                    notes[#notes+1]=c.name..": "..species.defs[id].assist.."."
                end
            end
        end
    end
        for _,i in ipairs(b.team) do
            local c=s.crew[i];local partner_cover=0
            for _,j in ipairs(b.team) do if j~=i then partner_cover=partner_cover+(contribution[j] or 0) end end
            if c.species=="cindercoil" and not unavailable(i) then
                if partner_cover<=0 then status(i,"partner","Needs cover from a partner")
                elseif remaining()>0 then status(i,"cover","Partner cover must stop all harm")
                else
                    b.used[i]=true;c.stamina=c.stamina-8;pressure=pressure+20
                    status(i,"trigger","Triggers: partner blocks the hit")
                    notes[#notes+1]=c.name..": Warmth display after partner cover."
                end
            end
        end
    b.resolve=math.max(0,b.resolve-pressure)
    local harm=b.resolve>0 and remaining() or 0
    if target=="cargo" then s.cargo=math.max(0,s.cargo-harm)
    else s.crew[target].condition=math.max(0,s.crew[target].condition-harm) end
    local all_down=true
    for _,i in ipairs(b.team) do if resources.ready(s.crew[i],4) then all_down=false end end
    local outcome
    if b.resolve<=0 then outcome="won"
    elseif all_down then outcome="fallback"
    elseif b.round>=b.limit then outcome=b.kind=="scavengers" and "won" or "fallback" end
    b.last="Pressure "..pressure.." / Cover "..(guard[target] or 0).." / Harm "..harm..(b.resolve==0 and " (repelled before the hit)." or ".")
    b.history[#b.history+1]={round=b.round,notes=notes,summary=b.last,target=target,damage=harm,pressure=pressure,cover=guard[target] or 0}
    if outcome then return true,outcome,abilities end
    b.round=b.round+1;intention(s)
    return true,nil,abilities
end
-- Preview the pending exchange with the same resolver on a private snapshot.
-- The saved RNG and live state are untouched; cosmetic timing cannot affect it.
function M.preview(s)
    if not M.automatic(s.battle) or s.battle.outcome then return nil end
    local copy=util.copy(s)
    local ok,outcome,abilities=M.step(copy)
    if not ok then return nil end
    local result={abilities=abilities,outcome=outcome,energy={}}
    for _,i in ipairs(s.battle.team) do result.energy[i]=s.crew[i].stamina-copy.crew[i].stamina end
    return result
end
return M
