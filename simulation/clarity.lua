local resources=require "simulation.resources"
local util=require "simulation.util"
local M={}
-- Existing readiness thresholds, not new penalties or a promise about weather.
function M.next_duty(s)
    local c=s.crew[s.hauler];local effort=resources.haul_effort(s,c)
    if not resources.hauler(s) then
        if c and c.condition<=0 then return {icon="condition",text=c.name.." needs care before hauling. Treat or reassign."} end
        if c and c.duty=="rest" then return {icon="haul",text=c.name.." is resting. Assign a working draft companion before travel."} end
        if c and c.stamina<effort then return {icon="stamina",text=c.name.." cannot haul: "..util.round(c.stamina).." / "..effort.." energy needed. Rest or reassign."} end
        return {icon="haul",text="Assign a ready draft companion in Crew before traveling."}
    end
    for _,member in ipairs(s.crew) do
        if member.species=="loamling" and not resources.ready(member,resources.effort(s,"loamling",18,"forage")) then
            return {icon="dig",text=member.name.." cannot help gather: needs "..resources.effort(s,"loamling",18,"forage").." energy and positive condition."}
        end
        if s.target<=4 and not s.flags.river_crossed and (member.species=="brindlehorn" or member.species=="reedskipper" or member.species=="slatewhorl") and not resources.ready(member,resources.effort(s,member.species,22,"river")) then
            return {icon="water",text=member.name.." cannot help at the crossing: needs "..resources.effort(s,member.species,22,"river").." energy and positive condition."}
        end
    end
    return {icon="haul",text=c.name.." is ready to haul at "..s.pace.." pace ("..effort.." energy needed to set off)."}
end
return M
