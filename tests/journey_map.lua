local model=require "simulation.expedition"
local util=require "simulation.util"
local map=require "presentation.route_map"
local motion=require "presentation.journey_motion"
return function(test,equal)
    test("overworld follows both real forks and exact saved progress without consuming RNG",function()
        for _,target in ipairs({2,5}) do
            for _,path in ipairs(require("content.forks")[target]) do
                local p=model.new(71);assert(model.command(p,"depart"))
                p.run.target=target;p.run.mode="landmark";p.run.progress=p.run.distance
                local before=util.copy(p);assert(#map.options(p.run)==2)
                equal(map.position(p.run),{x=map.places[target].x,y=map.places[target].y});equal(p,before)
                assert(model.command(p,"leave",{branch=path.id}))
                assert(map.branch(p.run,target+1)==path.id and p.run.distance==path.distance)
                equal(map.position(p.run),{x=map.places[target].x,y=map.places[target].y})
                local points=map.path(target+1,path.id)
                assert(points[2]==map.branches[path.id] and #points==3)
                p.run.progress=p.run.distance
                equal(map.position(p.run),{x=map.places[target+1].x,y=map.places[target+1].y})
                assert(#map.options(p.run)==0,"No branch action while traveling")
            end
        end
        local p=model.new(9);local original=util.copy(p)
        for _=1,40 do map.position(p.run);map.options(p.run) end
        equal(p,original)
    end)
    test("wagon reaches an encounter without replaying its paid day; focus and reduced motion are safe",function()
        local p=model.new(1848);assert(model.command(p,"depart"))
        local before={target=p.run.target,progress=p.run.progress}
        assert(model.command(p,"resume"));assert(model.command(p,"step"))
        if p.run.mode~="event" then assert(model.debug(p,"event","scavengers")) end
        local saved=util.copy(p);local draws=0
        local ui={snapshot=p,page="trail",has_focus=true,redraw=function() draws=draws+1 end}
        motion.begin(ui,before,"step");assert(ui.journey_motion)
        local start=motion.position(ui)
        for _=1,12 do motion.update(ui,.1) end
        local middle=motion.position(ui);assert(middle.x>start.x and middle.x<map.position(p.run).x)
        ui.has_focus=false;motion.update(ui,10);equal(middle,motion.position(ui))
        ui.has_focus=true;ui.page="journal";motion.update(ui,10);equal(middle,motion.position(ui))
        ui.page="trail";ui.save_error="disk full";motion.update(ui,10);equal(middle,motion.position(ui))
        ui.save_error=nil
        for _=1,20 do motion.update(ui,.1) end
        assert(not ui.journey_motion and draws==1);equal(motion.position(ui),map.position(p.run));equal(p,saved)
        motion.begin(ui,before,"step");p.settings.motion=false;motion.update(ui,.1);assert(not ui.journey_motion)
        motion.begin(ui,before,"step");assert(not ui.journey_motion)
        p.settings.motion=true;motion.begin(ui,before,"step");motion.cancel(ui);assert(not ui.journey_motion)
        local reloaded={snapshot=util.copy(saved)};equal(motion.position(reloaded),map.position(saved.run))
    end)
end
