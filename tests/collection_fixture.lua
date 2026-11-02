local model=require "simulation.expedition"
local collection=require "simulation.collection"
return function()
    local p=model.new(1848)
    assert(model.command(p,"crew",{species="reedskipper"}));assert(model.command(p,"crew",{species="bellmoth"}))
    collection.collect(p,"brindlehorn")
    for i=6,15 do collection.collect(p,model.species.order[(i-1)%6+1]) end
    return p
end
