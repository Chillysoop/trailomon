-- One paid Mossbell drill: temporary HP/supplies, existing carried gear.
local combat=require "simulation.wagon_combat"
local content=require "content.ambush"
local util=require "simulation.util"
local M={EFFORT=6}
function M.available(s)
    return s.mode=="landmark" and s.target==3 and s.courier_rules=="courier-v1" and ((s.wagon_practice and s.wagon_practice.battle.phase~="setup") or not s.flags.courier_done)
end
function M.ready(s,b)
    for _,u in ipairs(combat.crew(b)) do
        local found=combat.member(s,u.id)
        if not found or found.stamina<M.EFFORT or found.condition<=0 then return false,"Each companion needs 6 Energy and positive Condition" end
    end
    return true
end
function M.record(s)
    if not M.available(s) then return nil,"Practice is unavailable" end
    if s.wagon_practice then return util.copy(s.wagon_practice) end
    local crew=combat.ids(s.crew)
    local b=combat.new("guard",s.seed,crew,"mara")
    for i,u in ipairs(combat.crew(b)) do u.item=s.crew[i].work_item or "";u.name=combat.name(s,s.crew[i]) end
    return {battle=b,speed=1,carry=0}
end
function M.commit(snapshot,record)
    local s=snapshot.run
    if not M.available(s) then return nil,"Practice is unavailable" end
    local prior=s.wagon_practice
    if record.battle.scenario~="mara" or not require("services.ambush_save").validate(record) then return nil,"Invalid practice checkpoint" end
    if prior and prior.battle.phase~="setup" and record.battle.phase=="setup" then return nil,"Practice already used" end
    if #combat.crew(record.battle)~=#s.crew then return nil,"Practice crew changed" end
    for _,u in ipairs(combat.crew(record.battle)) do
        local found=combat.member(s,u.id)
        if not found or (u.item~="" and not (s.work_items or {})[u.item]) then return nil,"Use your traveling crew and carried items" end
    end
    local paying=record.battle.phase~="setup" and (not prior or prior.battle.phase=="setup")
    if paying then local ok,why=M.ready(s,record.battle);if not ok then return nil,why end end
    local copy=util.copy(snapshot)
    if paying then
        for _,c in ipairs(copy.run.crew) do c.stamina=c.stamina-M.EFFORT end
        copy.run.flags.courier_done=true;copy.run.flags.courier_sparred=true
    end
    for _,u in ipairs(record.battle.units) do
        if u.stats.attacks>0 or u.stats.casts>0 then require("simulation.journal_aims").exchange(copy.run);break end
    end
    copy.run.wagon_practice=util.copy(record)
    return copy
end
function M.valid(record,s)
    if record==nil then return true end
    if not require("services.ambush_save").validate(record) or record.battle.rules~=combat.RULES or record.battle.scenario~="mara" then return false end
    if record.battle.phase~="setup" and (not s.flags.courier_done or not s.flags.courier_sparred) then return false end
    return true
end
return M
