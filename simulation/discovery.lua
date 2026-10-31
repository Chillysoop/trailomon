local species=require "content.species"
local progression=require "simulation.progression"
local M={}
function M.arrive(snapshot)
    local s,p=snapshot.run,snapshot.profile
    if p.start_mode~="discovery" or s.mode~="landmark" then return end
    local id=s.target==2 and "loamling" or (s.target==3 and "bellmoth")
    if not id or p.roster[id] then return end
    for _,c in ipairs(s.crew) do if c.species==id then return end end
    local event="discover_"..id
    if s.seen[event] then return end
    s.seen[event]=true;s.pending={id=event,roll=0};s.mode="event"
    require("simulation.field_guide").observe(s,id)
end
function M.starter(snapshot,id)
    local s,p=snapshot.run,snapshot.profile
    if p.start_mode~="discovery" or p.last_committed~=0 or s.id~=1 or s.mode~="preparation" then return false,"Choose a first hauler only before your first departure" end
    if id~="brindlehorn" and id~="reedskipper" then return false,"Choose Brindlehorn or Reedskipper" end
    local c=progression.companion(id)
    if s.crew[1] then c.work_item=s.crew[1].work_item end
    p.starter=id;p.roster={[id]=progression.companion(id)};p.discoveries={[id]=true};s.crew={c};s.hauler=1
    return true
end
return M
