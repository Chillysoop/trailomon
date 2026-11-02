-- Explicit pre-S30 journey fixture. Production new runs use wagon-road-v1.
local model=require "simulation.expedition"
return setmetatable({new=function(...)
    local p=model.new(...);p.run.road_combat_rules=nil;return p
end},{__index=model})
