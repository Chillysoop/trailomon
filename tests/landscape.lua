local landscape=require "presentation.landscape"
local model=require "simulation.expedition"
local util=require "simulation.util"
return function(test,equal)
    test("scenery follows arrivals, chosen branches and the actual delivery outcome",function()
        local p=model.new(1848);local s=p.run
        assert(landscape.place(s)=="depot")
        assert(model.command(p,"depart"));assert(landscape.place(s)=="depot")
        s.progress=s.distance*.5;assert(landscape.place(s)=="meadow")
        s.progress=s.distance;s.mode="landmark";assert(landscape.place(s)=="split")
        assert(model.command(p,"leave",{branch="woodland"}));assert(landscape.place(s)=="woodland")
        s.progress=s.distance;s.mode="landmark";assert(landscape.place(s)=="outpost")
        s.target=5;s.mode="landmark";assert(landscape.place(s)=="gate")
        assert(model.command(p,"leave",{branch="gorge"}));assert(landscape.place(s)=="gorge")
        local before=util.copy(s);landscape.place(s);equal(s,before)
        s.mode="result";s.outcome="returned";assert(landscape.place(s)=="gorge")
        s.outcome="delivered";assert(landscape.place(s)=="reach")
        s.outcome="late";assert(landscape.place(s)=="reach")
    end)
    test("landscape drawing stays inside every production viewport without mutating the journey",function()
        local p=model.new(1848);assert(model.command(p,"depart"))
        for target=2,6 do for _,mode in ipairs({"stopped","landmark"}) do
            for _,terrain in ipairs({"meadow","woodland","marsh","upland","ridge","gorge"}) do
                for _,height in ipairs({155,180,230}) do
                    local s=util.copy(p.run);s.target=target;s.mode=mode;s.terrain=terrain
                    s.progress=s.distance*.5
                    local before=util.copy(s);local count=0
                    landscape.draw({}, {rect=function(_,x,y,w,h)
                        assert(x>=28 and y>=307 and w>0 and h>0)
                        assert(x+w<=862 and y+h<=307+height)
                        count=count+1
                    end},28,307,834,height,s)
                    assert(count>0 and count<500);equal(s,before)
                end
            end
        end end
    end)
end
