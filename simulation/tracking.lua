-- A clue is fixed when a stretch begins. Inspection never consumes random state.
local rng=require "simulation.rng"
local resources=require "simulation.resources"
local species=require "content.species"
local M={}
local habitats={meadow={"brindlehorn","loamling"},woodland={"bellmoth","cindercoil","loamling"},marsh={"reedskipper","cindercoil"},upland={"slatewhorl","cindercoil"},ridge={"slatewhorl","cindercoil"},gorge={"slatewhorl","cindercoil"}}
local terrain_index={meadow=1,woodland=2,marsh=3,upland=4,ridge=5,gorge=6}
M.signs={brindlehorn="Split hoofprints",reedskipper="Reed platforms",loamling="Fresh root diggings",bellmoth="Wing scales under bark",cindercoil="Warm bedding",slatewhorl="Grooves in loose stone"}
local allowed={meet_brindlehorn="brindlehorn",meet_reedskipper="reedskipper",wild_brindlehorn="brindlehorn",wild_reedskipper="reedskipper",track_loamling="loamling",discover_loamling="loamling",wild_bellmoth="bellmoth",discover_bellmoth="bellmoth",cinder_shelter="cindercoil",cinder_return="cindercoil",slate_tracks="slatewhorl",slate_return="slatewhorl"}
local function event_for(snapshot,id)
    local s,p=snapshot.run,snapshot.profile
    if id=="cindercoil" then return s.flags.cinder_helped and not p.roster[id] and not s.seen.cinder_return and "cinder_return" or "cinder_shelter" end
    if id=="slatewhorl" then return s.flags.slate_helped and not p.roster[id] and not s.seen.slate_return and "slate_return" or "slate_tracks" end
    if p.start_mode=="discovery" and not p.roster[id] then
        for _,c in ipairs(s.crew) do if c.species==id then return id=="loamling" and "track_loamling" or "wild_"..id end end
        return (id=="brindlehorn" or id=="reedskipper") and "meet_"..id or "discover_"..id
    end
    return id=="loamling" and "track_loamling" or "wild_"..id
end
function M.enter(snapshot)
    local s=snapshot.run
    if not s.tracks or s.tracks[tostring(s.target)] then return end
    local candidates={}
    for _,id in ipairs(habitats[s.terrain]) do
        local event=event_for(snapshot,id)
        if not s.seen[event] then candidates[#candidates+1]={species=id,event=event} end
    end
    if #candidates==0 then return end
    local stream={clue=rng.seed(s.seed+s.target*7919+terrain_index[s.terrain]*113)}
    rng.next(stream,"clue") -- Mix adjacent expedition seeds before choosing a species.
    local record=candidates[rng.int(stream,"clue",1,#candidates)]
    record.roll=rng.next(stream,"clue");record.empty=record.roll<0.2;record.used=false
    s.tracks[tostring(s.target)]=record
end
function M.preview(snapshot)
    local s=snapshot.run;local record=(s.tracks or {})[tostring(s.target)]
    local need=resources.daily_food(s)
    local reason
    if s.mode~="stopped" and s.mode~="traveling" and s.mode~="landmark" then reason="Stop outside an encounter first."
    elseif s.road_story then reason="Read the road note first."
    elseif not s.tracks then reason="Track searches start with your next expedition."
    elseif not record then reason="No fresh clues remain on this stretch."
    elseif record.used then reason="This stretch has already been searched."
    elseif s.seen[record.event] then reason="You already found the source of these tracks."
    elseif s.day>=31 then reason="The road closes tomorrow; no time to search."
    elseif s.food<need then reason="Pack "..need.." provisions for the search day first." end
    return {record=record,available=not reason,reason=reason,meals=need,days=1,
        name=record and species.defs[record.species].name or "No fresh signs",sign=record and M.signs[record.species] or "No trail to follow"}
end
function M.valid(records)
    if records==nil then return true end
    if type(records)~="table" then return false end
    for key,r in pairs(records) do
        if type(key)~="string" or not key:match("^[2-6]$") or type(r)~="table" or not species.defs[r.species] or allowed[r.event]~=r.species then return false end
        if type(r.roll)~="number" or r.roll~=r.roll or r.roll<0 or r.roll>=1 or type(r.empty)~="boolean" or type(r.used)~="boolean" or r.empty~=(r.roll<0.2) then return false end
    end
    return true
end
return M
