local model=require "simulation.expedition"
local util=require "simulation.util"
local progression=require "simulation.progression"
local reports=model.trail_reports
return function(test,command,valid,equal)
    local function fork(target,seed)
        local p=model.new(seed or 1848);command(p,"depart")
        p.run.target=target;p.run.distance=model.route[target].distance;p.run.progress=p.run.distance;p.run.mode="landmark"
        return p
    end
    test("fork reports are pure, repeatable and compatible with older saves",function()
        for _,target in ipairs({2,5}) do
            local p=fork(target);local before=util.copy(p);local report=reports.get(p.run)
            for i=1,20 do equal(report,reports.get(p.run)) end
            equal(before,p);valid(p)
            local resumed=util.copy(p);valid(resumed);equal(report,reports.get(resumed.run))
            resumed.run.rng={weather=123,events=456,combat=789}
            equal(report,reports.get(resumed.run)) -- No leaked knowledge of future rolls.
        end
        local p=model.new(7);assert(not reports.get(p.run))
        command(p,"depart");assert(not reports.get(p.run))
        for _,target in ipairs({3,4,6}) do assert(not reports.get(fork(target).run)) end
    end)
    test("reported routes commit their actual distances without changing later outcomes",function()
        for _,target in ipairs({2,5}) do
            for index=1,2 do
                for seed=1,12 do
                    local p=fork(target,seed);local untouched=util.copy(p)
                    local route=reports.get(p.run).routes[index]
                    for i=1,5 do reports.get(p.run) end
                    command(p,"leave",{branch=route.id});command(untouched,"leave",{branch=route.id})
                    assert(p.run.distance==route.distance and p.run.terrain==route.id)
                    assert(model.advance_day(p,true,false));assert(model.advance_day(untouched,true,false))
                    equal(p,untouched);valid(p)
                end
            end
        end
    end)
    test("reports distinguish current evidence from missing upland reports",function()
        local p=fork(2);local s=p.run
        for _,weather in ipairs({"clear","rain","cold"}) do
            s.weather=weather
            local r=reports.get(s);assert(r.source:find("UNCERTAIN") and #r.routes==2)
            assert(r.reminder:find("not a forecast",1,true))
        end
        s.target=5
        local r=reports.get(s)
        assert(r.source:find("UNKNOWN") and r.outlook:find("No fresh report",1,true))
        assert(r.reminder:find("day 32",1,true))
    end)
    test("crew guidance honors energy, condition and working duty",function()
        local s=fork(2).run
        assert(reports.get(s).routes[1].help.text:find("ready to find",1,true))
        s.crew[2].stamina=17
        assert(reports.get(s).routes[1].help.text:find("needs care",1,true))
        s.crew[2]=progression.companion("cindercoil")
        assert(reports.get(s).routes[2].help.text:find("reduces rain damage",1,true))
        s.crew[2].duty="rest"
        assert(reports.get(s).routes[2].help.text:find("Work duty",1,true))
        s.crew[2].duty="work";s.crew[2].condition=0
        assert(reports.get(s).routes[2].help.text:find("positive condition",1,true))
    end)
    test("item advice follows packed, equipped and transferred items without overstating protection",function()
        local p=fork(5);local s=p.run;s.work_items={padded_trace=true,dry_wrap=true}
        assert(reports.get(s).routes[1].help.text:find("is packed",1,true))
        command(p,"equip_work_item",{member=1,item="padded_trace"})
        assert(reports.get(s).routes[1].help.text:find("does not reduce wagon wear",1,true))
        command(p,"equip_work_item",{member=2,item="padded_trace"})
        assert(reports.get(s).routes[1].help.text:find("Equip it on your hauler",1,true))
        command(p,"equip_work_item",{member=2,item="dry_wrap"});s.target=2
        assert(reports.get(s).routes[2].help.text:find("does not protect cargo",1,true))
    end)
    test("terrain report claims match actual first-day travel and gathering rules",function()
        local traveled={}
        for _,target in ipairs({2,5}) do
            for _,route in ipairs(reports.get(fork(target).run).routes) do
                local p=fork(target);command(p,"leave",{branch=route.id})
                local s=p.run;s.pace="hurried";s.cooldown=99
                assert(model.advance_day(p,true,false))
                traveled[route.id]={progress=s.progress,wear=100-s.wagon,cargo=100-s.cargo,food=model.forage_preview(s).gross}
            end
        end
        local m,w,r,g=traveled.meadow,traveled.woodland,traveled.ridge,traveled.gorge
        assert(math.abs(w.progress/m.progress-0.9)<0.00001 and w.food==m.food)
        assert(math.abs(r.progress/m.progress-1.05)<0.00001)
        assert(math.abs(g.progress/m.progress-0.9)<0.00001)
        assert(math.abs(r.wear-g.wear-0.6)<0.00001 and r.cargo-g.cargo==2 and m.food-g.food==4)
    end)
end
