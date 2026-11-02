-- Owned individuals live at Fernwake; only the selected party travels/eats/fights.
local util=require "simulation.util"
local species=require "content.species"
local M={RULES="collection-v1",LIMIT=4}
function M.companion(id)
    local def=species.defs[id]
    return {species=id,name=def.friend,temperament=def.temperament,condition=100,stamina=100,trust=1,memories={},duty="work"}
end
function M.enabled(s) return s.collection_rules==M.RULES end
function M.find(p,uid)
    for i,c in ipairs(p.collection or {}) do if c.uid==uid then return c,i end end
end
function M.add(p,c)
    local owned=util.copy(c);owned.uid=p.next_companion_id;p.next_companion_id=p.next_companion_id+1
    owned.work_item=nil;p.collection[#p.collection+1]=owned
    return owned
end
function M.ensure(snapshot)
    local p,s=snapshot.profile,snapshot.run
    if not p.collection then
        p.collection={};p.next_companion_id=1
        for _,id in ipairs(species.order) do if p.roster[id] then M.add(p,p.roster[id]) end end
    end
    for _,c in ipairs(s.crew) do
        if not c.uid then
            for _,owned in ipairs(p.collection) do if owned.species==c.species then c.uid=owned.uid;break end end
            if not c.uid then c.uid=M.add(p,c).uid end
        end
    end
    s.collection_rules=M.RULES
end
function M.prepare(snapshot)
    M.ensure(snapshot)
    local p,s=snapshot.profile,snapshot.run
    if p.party and #p.party>0 then
        s.crew={}
        for _,uid in ipairs(p.party) do s.crew[#s.crew+1]=util.copy(assert(M.find(p,uid))) end
    end
end
function M.collect(snapshot,id)
    local p,s=snapshot.profile,snapshot.run
    local owned=M.add(p,M.companion(id))
    p.roster[id]=p.roster[id] or util.copy(owned);p.discoveries[id]=true;s.discoveries[id]=true
    local traveling=#s.crew<M.LIMIT
    if traveling then s.crew[#s.crew+1]=util.copy(owned) end
    return owned,traveling
end
function M.select(snapshot,uid)
    local p,s=snapshot.profile,snapshot.run
    if not M.enabled(s) or s.mode~="preparation" then return false,"Change your party at Fernwake before departure" end
    local owned,index=M.find(p,uid)
    if not owned then return false,"Companion is not in your collection" end
    for i,c in ipairs(s.crew) do if c.uid==uid then
        local stored=util.copy(c);stored.work_item=nil;p.collection[index]=stored
        table.remove(s.crew,i)
        s.hauler=s.hauler==i and 1 or (s.hauler>i and s.hauler-1 or s.hauler)
        return true
    end end
    if #s.crew>=M.LIMIT then return false,"Party full (4). Store a companion first" end
    s.crew[#s.crew+1]=util.copy(owned);return true
end
function M.remember_party(snapshot)
    local p,s=snapshot.profile,snapshot.run;p.party={}
    for _,c in ipairs(s.crew) do p.party[#p.party+1]=c.uid end
end
function M.home(p,c)
    local _,index=M.find(p,c.uid)
    assert(index,"Missing collected companion")
    p.collection[index]=util.copy(c)
end
function M.valid(p,s,companion)
    if not p.collection then return s.collection_rules==nil and p.next_companion_id==nil and p.party==nil end
    if not M.enabled(s) or type(p.collection)~="table" or type(p.next_companion_id)~="number" or p.next_companion_id%1~=0 or p.next_companion_id<1 then return false end
    local found,count={},0
    for index,c in pairs(p.collection) do
        if type(index)~="number" or index%1~=0 or index<1 or index>#p.collection or not companion(c) or c.work_item then return false end
        if type(c.uid)~="number" or c.uid%1~=0 or c.uid<1 or c.uid>=p.next_companion_id or found[c.uid] then return false end
        found[c.uid]=c;count=count+1
    end
    if count~=#p.collection then return false end
    local crew={}
    for _,c in ipairs(s.crew) do
        if not found[c.uid] or found[c.uid].species~=c.species or crew[c.uid] then return false end
        crew[c.uid]=true
    end
    if p.party then
        if type(p.party)~="table" or #p.party<1 or #p.party>M.LIMIT then return false end
        local seen={};for _,uid in ipairs(p.party) do if not found[uid] or seen[uid] then return false end;seen[uid]=true end
    end
    return true
end
return M
