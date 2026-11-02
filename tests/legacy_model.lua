-- Explicit historical journey fixture; never silently adopts later balance rules.
local model=require "simulation.expedition"
return setmetatable({new=function(...)
    local p=model.new(...);p.profile.collection=nil;p.profile.next_companion_id=nil;p.profile.party=nil;p.run.collection_rules=nil;
    for _,c in ipairs(p.run.crew) do c.uid=nil end
    p.run.road_combat_rules=nil;p.run.recovery_rules=nil;return p
end},{__index=model})
