local species=require "content.species"
local util=require "simulation.util"
local M={}
function M.companion(id)
    local def=species.defs[id]
    return {species=id,name=def.friend,temperament=def.temperament,condition=100,stamina=100,trust=1,memories={},duty="work"}
end
function M.profile()
    local p={roster={},discoveries={},history={},covered=false,next_id=1,last_committed=0}
    for _, id in ipairs(species.order) do
        if species.defs[id].initial then p.roster[id]=M.companion(id); p.discoveries[id]=true end
    end
    return p
end
function M.memory(c, text)
    if c.memories[#c.memories]==text then return end
    c.memories[#c.memories+1]=text
    if #c.memories>6 then table.remove(c.memories,1) end
end
function M.commit(p,s)
    if s.id<=p.last_committed then return false end
    for _, c in ipairs(s.crew) do
        M.memory(c, s.outcome=="delivered" and "Brought orchard cuttings to Lantern Reach." or "Came home after a difficult journey.")
        local home=util.copy(c)
        home.condition,home.stamina,home.duty=100,100,"work"
        home.work_item=nil -- Supplies are packed afresh for each expedition.
        home.trust=math.min(3,home.trust+1)
        p.roster[c.species]=home
        p.discoveries[c.species]=true
    end
    for id in pairs(s.discoveries) do p.discoveries[id]=true end
    if s.flags.river_inspected and s.flags.river_crossed then p.covered=true end
    p.history[#p.history+1]={id=s.id,seed=s.seed,day=s.day,outcome=s.outcome,cargo=s.cargo,route=util.copy(s.branches),summary=s.ending}
    if #p.history>10 then table.remove(p.history,1) end
    p.last_committed=s.id
    return true
end
return M
