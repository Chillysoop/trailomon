-- Optional records only: no RNG, resource rewards, or changes to journey rules.
local species=require "content.species"
local util=require "simulation.util"
local M={order={"company","paths","peaceful"}}
M.defs={
    company={title="Fresh company",icon="crew",description="Deliver on time with two different departure pairs. Order and names do not matter; recruits do not change the pair."},
    paths={title="Both ways through",icon="map",description="Reach Lantern Reach by the ridge and by the gorge across journeys. A late arrival still records the path."},
    peaceful={title="A quiet passage",icon="trail",description="Reach Lantern Reach without playing a combat exchange. Inspecting positions or withdrawing before the first exchange is allowed."},
}
function M.empty() return {pairs={},paths={},completed={}} end
function M.pair(crew)
    if #crew~=2 then return nil end
    local ids={crew[1].species,crew[2].species};table.sort(ids)
    return table.concat(ids,"+")
end
local function count(t) local n=0;for _ in pairs(t) do n=n+1 end;return n end
local function arrived(s) return s.outcome=="delivered" or s.outcome=="late" end

-- Old histories prove arrival paths, but do not prove departure crews or combat.
-- Reading this projection never writes to the profile or current expedition.
function M.records(p)
    local a=p.aims and util.copy(p.aims) or M.empty()
    for _,h in ipairs(p.history) do
        local path=h.route.last
        if arrived(h) and (path=="ridge" or path=="gorge") and not a.paths[path] then a.paths[path]=h.id end
    end
    if a.paths.ridge and a.paths.gorge and not a.completed.paths then
        a.completed.paths=math.max(a.paths.ridge,a.paths.gorge)
    end
    return a
end
function M.depart(s) s.aim_journey={pair=M.pair(s.crew),fought=false} end
function M.exchange(s) if s.aim_journey then s.aim_journey.fought=true end end
function M.commit(p,s)
    local a=M.records(p);local added={}
    local function award(id)
        if not a.completed[id] then a.completed[id]=s.id;added[#added+1]=id end
    end
    if arrived(s) then
        local path=s.branches.last
        if path=="ridge" or path=="gorge" then a.paths[path]=a.paths[path] or s.id end
        if a.paths.ridge and a.paths.gorge then award("paths") end
        if s.aim_journey then
            if s.outcome=="delivered" and s.aim_journey.pair then
                a.pairs[s.aim_journey.pair]=a.pairs[s.aim_journey.pair] or s.id
                if count(a.pairs)>=2 then award("company") end
            end
            if not s.aim_journey.fought then award("peaceful") end
        end
    end
    p.aims=a
    return added
end
function M.rows(snapshot)
    local p,s=snapshot.profile,snapshot.run;local a=M.records(p);local rows={}
    local pair=s.mode=="preparation" and M.pair(s.crew) or (s.aim_journey and s.aim_journey.pair)
    local notes={
        company=(s.mode~="preparation" and not s.aim_journey) and "This older save has no departure-pair record. Tracking starts on your next journey." or
            (not pair and "Choose two companions at departure to record a delivery pair." or
            (a.pairs[pair] and "This departure pair is already recorded. Try a different pair next time." or "This departure pair has no recorded delivery yet.")),
        paths="Ridge: "..(a.paths.ridge and "recorded" or "not yet").." / Gorge: "..(a.paths.gorge and "recorded" or "not yet"),
        peaceful=s.mode=="preparation" and "Tracking begins when you leave Fernwake." or
            (not s.aim_journey and "This older save has no combat record. Try this aim on your next departure." or
            (s.aim_journey.fought and "An exchange was played. Try again on your next journey." or "No combat exchanges played. Reach Lantern Reach to complete this aim.")),
    }
    local progress={company=math.min(2,count(a.pairs)).." / 2 pairs",paths=count(a.paths).." / 2 paths",peaceful="0 / 1 arrival"}
    for _,id in ipairs(M.order) do
        local d=M.defs[id];local done=a.completed[id]
        rows[#rows+1]={id=id,title=d.title,icon=d.icon,description=d.description,done=done~=nil,
            status=done and "COMPLETED" or progress[id],note=done and ("Recorded on journey "..done..". This accomplishment stays in your journal.") or notes[id]}
    end
    return rows
end

local function identity(n,max) return util.finite(n) and n>=1 and n<=max and n==math.floor(n) end
local function valid_pair(key)
    if type(key)~="string" then return false end
    local a,b=key:match("^([a-z]+)%+([a-z]+)$")
    return a and b and a<b and species.defs[a]~=nil and species.defs[b]~=nil
end
function M.valid_profile(a,max)
    if a==nil then return true end
    if type(a)~="table" or type(a.pairs)~="table" or type(a.paths)~="table" or type(a.completed)~="table" then return false end
    for key,id in pairs(a.pairs) do if not valid_pair(key) or not identity(id,max) then return false end end
    for key,id in pairs(a.paths) do if (key~="ridge" and key~="gorge") or not identity(id,max) then return false end end
    for key,id in pairs(a.completed) do if not M.defs[key] or not identity(id,max) then return false end end
    if a.completed.company and count(a.pairs)<2 then return false end
    if a.completed.paths and not (a.paths.ridge and a.paths.gorge) then return false end
    return true
end
function M.valid_journey(a)
    return a==nil or (type(a)=="table" and type(a.fought)=="boolean" and (a.pair==nil or valid_pair(a.pair)))
end
return M
