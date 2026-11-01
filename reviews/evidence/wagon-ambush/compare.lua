-- Run from repository root: .tools/luajit-64.exe reviews/evidence/wagon-ambush/compare.lua
local c=require "simulation.wagon_combat"
io.write("seed,formation,result,seconds,wagon,intercepts,followups,casts\n")
for seed=1,24 do
    for _,preset in ipairs({"guard","rush"}) do
        local s=c.new(preset,seed);c.start(s);c.step(s,1800);assert(c.validate(s))
        local moss,ember,lumen=c.unit(s,"moss"),c.unit(s,"ember"),c.unit(s,"lumen")
        io.write(string.format("%d,%s,%s,%.1f,%d,%d,%d,%d\n",seed,preset,s.result,s.tick/10,s.wagon.hp,moss.stats.intercepts,ember.stats.reactions,moss.stats.casts+ember.stats.casts+lumen.stats.casts))
    end
end
