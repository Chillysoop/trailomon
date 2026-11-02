-- Journey-owned combat checkpoint. Rendering never owns expedition accounting.
local util=require "simulation.util"
local combat=require "simulation.wagon_combat"
local content=require "content.ambush"
local M={RULES="wagon-road-v1",EFFORT=6}
local function clamp(v) return math.max(0,math.min(100,v)) end
local function member(s,id)
    return combat.member(s,id)
end
function M.active(s) return s.mode=="wagon_combat" and s.wagon_battle~=nil end
function M.ready(s,b)
    if b.wagon.hp<=0 then return false,"Wagon disabled / withdraw and repair" end
    for _,u in ipairs(combat.crew(b)) do if u.hp>0 then return true end end
    return false,"Crew needs 6 Energy and positive Condition / withdraw"
end
function M.open(s,kind)
    if not content.road[kind] then return false end
    local ids=combat.ids(s.crew)
    local b=combat.new("guard",s.rng.combat,ids,kind)
    local initial={crew={},wagon=s.wagon,food=s.food,cargo=s.cargo,day=s.day,medicine=s.medicine,repairs=s.repairs}
    for _,u in ipairs(combat.crew(b)) do
        local c=member(s,u.id)
        local active=c.stamina>=M.EFFORT and c.condition>0
        u.hp=active and math.max(1,math.floor(u.max_hp*c.condition/100)) or 0
        u.item=c.work_item or "";u.name=combat.name(s,c)
        initial.crew[u.id]={condition=c.condition,stamina=c.stamina,hp=u.hp,active=active}
    end
    b.wagon.hp=math.floor(s.wagon);initial.wagon_hp=b.wagon.hp
    for _,id in ipairs({"medicine","repairs"}) do b.supplies[id]=math.min(1,s[id]) end
    s.wagon_battle={battle=b,speed=1,carry=0,initial=initial,charged=false,settled=false}
    s.mode="wagon_combat";s.encounter=kind;return true
end
function M.can_back(s) return M.active(s) and s.pending~=nil and not s.wagon_battle.charged and not s.wagon_battle.settled end
local function exchanged(b)
    for _,u in ipairs(b.units) do if u.stats.attacks>0 or u.stats.casts>0 then return true end end
    return false
end
function M.apply_condition(s)
    local r=s.wagon_battle;local b=r.battle
    s.wagon=clamp(r.initial.wagon+(b.wagon.hp-r.initial.wagon_hp))
    if b.wagon.hp==0 then s.wagon=0 end
    for _,u in ipairs(combat.crew(b)) do
        local c=member(s,u.id);local before=r.initial.crew[u.id]
        if before.active then c.condition=u.hp==0 and 0 or clamp(before.condition+(u.hp-before.hp)*100/u.max_hp) end
    end
end
local function commit_choice(s,b)
    if s.pending then
        M.log(s,"Defend the wagon / "..b.scenario..".")
        s.pending=nil;s.cooldown=3
    end
    s.rng.combat=b.rng
end
function M.apply(snapshot,record)
    local s=snapshot.run;local old=s.wagon_battle
    if not M.active(s) or not require("services.ambush_save").validate(record) then return false,"Invalid road checkpoint" end
    local b=record.battle
    if b.scenario~=old.battle.scenario or b.rules~=combat.RULES or b.seed~=old.battle.seed or b.tick<old.battle.tick then return false,"Road encounter changed" end
    if old.settled and (b.phase~="result" or b.result~=old.battle.result or b.tick~=old.battle.tick) then return false,"Encounter already settled" end
    if old.battle.phase~="setup" and b.phase=="setup" then return false,"Formation already locked" end
    if #combat.crew(b)~=#s.crew then return false,"Traveling crew changed" end
    for _,u in ipairs(combat.crew(b)) do
        if not member(s,u.id) or not old.initial.crew[u.id] or (u.item~="" and not (s.work_items or {})[u.item]) then return false,"Use carried crew and gear" end
    end
    for _,id in ipairs({"medicine","repairs"}) do
        if b.used[id]<old.battle.used[id] or b.supplies[id]+b.used[id]~=math.min(1,old.initial[id]) then return false,"Supply accounting changed" end
    end
    local r=util.copy(old);r.battle=util.copy(b);r.speed=record.speed;r.carry=record.carry
    local acted=exchanged(b)
    local spent=b.used.medicine+b.used.repairs>0
    if not r.charged and (acted or spent) then
        for _,u in ipairs(combat.crew(b)) do
            local c=member(s,u.id)
            if r.initial.crew[u.id].active then c.stamina=c.stamina-M.EFFORT end
            c.work_item=u.item~="" and u.item or nil
        end
        r.charged=true;commit_choice(s,b)
    end
    if acted then require("simulation.journal_aims").exchange(s) end
    for _,id in ipairs({"medicine","repairs"}) do s[id]=s[id]-(b.used[id]-old.battle.used[id]) end
    s.wagon_battle=r
    if b.phase=="result" and not r.settled then
        commit_choice(s,b)
        M.apply_condition(s)
        r.settled=true
        M.on_end(snapshot,b.result)
        r.receipt={wagon=s.wagon-r.initial.wagon,food=s.food-r.initial.food,cargo=s.cargo-r.initial.cargo,
            days=s.day-r.initial.day,medicine=-b.used.medicine,repairs=-b.used.repairs,crew={}}
        for _,u in ipairs(combat.crew(b)) do
            local c=member(s,u.id);local before=r.initial.crew[u.id]
            r.receipt.crew[u.id]={energy=c.stamina-before.stamina,condition=c.condition-before.condition}
        end
    end
    return true
end
function M.commit(snapshot,record)
    local candidate=util.copy(snapshot);local ok,why=M.apply(candidate,record)
    if not ok then return nil,why end
    return candidate
end
function M.command(snapshot,action,arg)
    local s=snapshot.run;if not M.active(s) then return false end
    arg=arg or {};local r=util.copy(s.wagon_battle);local b=r.battle;local ok
    if action=="start" then
        local ready,why=M.ready(s,b);if not ready then return false,why end
        ok=combat.start(b)
    elseif action=="step" and b.phase=="fight" then combat.step(b,arg.ticks or 10);ok=true
    elseif action=="move" then ok=combat.move(b,arg.id,arg.position)
    elseif action=="equip" then ok=combat.equip(b,arg.id,arg.item)
    elseif action=="supply" then ok=combat.supply(b,arg.id)
    elseif action=="retreat" then
        if b.phase=="setup" then combat.start(b) end
        ok=combat.retreat(b)
    elseif action=="continue" and r.settled then s.wagon_battle=nil;s.encounter=nil;s.mode="stopped";return true
    else return false,"Unavailable road action" end
    if not ok then return false,"Unavailable road action" end
    return M.apply(snapshot,r)
end
local function number(v,lo,hi) return util.finite(v) and v>=lo and v<=hi end
function M.valid(s)
    if s.road_combat_rules~=nil and s.road_combat_rules~=M.RULES then return false end
    local r=s.wagon_battle
    if not r then return s.mode~="wagon_combat" end
    if s.road_combat_rules~=M.RULES or s.mode~="wagon_combat" or s.battle~=nil or not require("services.ambush_save").validate(r) then return false end
    local b=r.battle;local i=r.initial
    if b.rules~=combat.RULES or not content.road[b.scenario] or s.encounter~=b.scenario or type(r.charged)~="boolean" or type(r.settled)~="boolean" then return false end
    if r.settled~=(b.phase=="result") or type(i)~="table" or type(i.crew)~="table" or #combat.crew(b)~=#s.crew then return false end
    if not number(i.wagon,0,100) or i.wagon_hp~=math.floor(i.wagon) or not number(i.cargo,0,100) or not number(i.food,0,10000) or not number(i.day,1,s.day) then return false end
    if r.charged and s.pending or r.settled and s.pending then return false end
    if r.charged~=(exchanged(b) or b.used.medicine+b.used.repairs>0) then return false end
    if b.phase=="setup" and (r.charged or b.tick~=0) then return false end
    for _,id in ipairs({"medicine","repairs"}) do
        if not number(i[id],0,10000) or i[id]%1~=0 or b.used[id]+b.supplies[id]~=math.min(1,i[id]) or s[id]~=i[id]-b.used[id] then return false end
    end
    for _,u in ipairs(combat.crew(b)) do
        local c=member(s,u.id);local v=i.crew[u.id]
        if not c or type(v)~="table" or not number(v.condition,0,100) or not number(v.stamina,0,100) or type(v.active)~="boolean" then return false end
        if v.active~=(v.condition>0 and v.stamina>=M.EFFORT) or v.hp~=(v.active and math.max(1,math.floor(u.max_hp*v.condition/100)) or 0) then return false end
        if b.phase=="setup" and u.hp~=v.hp then return false end
        if u.item~="" and not (s.work_items or {})[u.item] then return false end
        if not r.settled and (c.condition~=v.condition or c.stamina~=v.stamina-(r.charged and v.active and M.EFFORT or 0)) then return false end
    end
    if not r.settled and (s.wagon~=i.wagon or s.food~=i.food or s.cargo~=i.cargo or s.day~=i.day) then return false end
    if r.settled then
        local receipt=r.receipt
        if type(receipt)~="table" or type(receipt.crew)~="table" then return false end
        for _,id in ipairs({"wagon","cargo","food","medicine","repairs"}) do if receipt[id]~=s[id]-i[id] then return false end end
        if receipt.days~=s.day-i.day then return false end
        for _,u in ipairs(combat.crew(b)) do
            local c=member(s,u.id);local v=receipt.crew[u.id]
            if type(v)~="table" or v.energy~=c.stamina-i.crew[u.id].stamina or v.condition~=c.condition-i.crew[u.id].condition then return false end
        end
    end
    return true
end
return M
