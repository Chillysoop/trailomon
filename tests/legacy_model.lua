-- Explicit historical journey fixture; never silently adopts later balance rules.
local model=require "simulation.expedition"
return setmetatable({new=function(...)
    local p=model.new(...);p.run.road_combat_rules=nil;p.run.recovery_rules=nil;return p
end},{__index=model})
