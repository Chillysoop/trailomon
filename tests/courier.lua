local model=require "simulation.expedition"
local util=require "simulation.util"
local progression=require "simulation.progression"
local courier=require "simulation.courier"
return function(test,command,valid,equal)
    local function start(a,b)
        local p=model.new(8);command(p,"depart");p.run.target=3;p.run.progress=p.run.distance;p.run.mode="landmark"
        p.run.crew={progression.companion(a or "brindlehorn"),progression.companion(b or "loamling")}
        command(p,"courier");command(p,"choice",{id="battle"});command(p,"battle_start",{team={1,2}});return p
    end
    test("courier practice preserves cargo condition supplies and exact previews",function()
        for _,a in ipairs(model.species.order) do for _,b in ipairs(model.species.order) do if a~=b then
            local p=start(a,b);local initial=util.copy(p.run);local resumed=util.copy(p)
            while p.run.mode=="combat" do
                local before=util.copy(p);local forecast=model.combat.preview(p.run);equal(before,p)
                command(p,"battle_step");command(resumed,"battle_step");equal(p,resumed)
                for _,i in ipairs({1,2}) do
                    assert(p.run.crew[i].condition==initial.crew[i].condition)
                    assert(before.run.crew[i].stamina-p.run.crew[i].stamina==forecast.energy[i])
                end
            end
            for _,k in ipairs({"cargo","food","coins","day","wagon","traveler"}) do assert(p.run[k]==initial[k],k) end
            assert(p.run.flags.courier_sparred and p.run.crew[1].stamina<100)
            command(p,"battle_continue");assert(p.run.mode=="landmark");assert(not model.command(p,"courier"))
        end end end
    end)
    test("courier inspection, skip and exhausted withdrawal are safe and once only",function()
        local p=start();local initial=util.copy(p.run.rng);command(p,"battle_back");equal(initial,p.run.rng)
        command(p,"choice",{id="pass"});assert(p.run.mode=="landmark" and p.run.flags.courier_done)
        assert(not model.command(p,"courier"));assert(p.run.crew[1].stamina==100)
        p=start();p.run.crew[1].stamina=3;p.run.crew[2].stamina=3
        command(p,"battle_step");assert(p.run.mode=="combat_result" and p.run.battle.outcome=="fallback")
        assert(p.run.food==90 and p.run.cargo==100 and p.run.day==1)
        p=start();command(p,"withdraw");assert(p.run.battle.result.cargo==0 and p.run.battle.result.days==0)
        local bad=start();bad.run.battle.practice=-1;assert(not require("services.save").validate(bad))
    end)
    test("optional practice runs finish and repeat without soft-locks",function()
        local runner=require "tools.report.runner";local policy=require "tools.report.policy"
        local function play(p,strategy)
            local s=p.run
            if not s.road_story and s.mode=="landmark" and s.target==3 and not s.flags.courier_done then return "courier",{},"one optional practice" end
            return policy.next(p,strategy)
        end
        local days=0
        for seed=1,12 do
            local p=model.new(seed)
            local control=runner.run(p,"careful")
            local a=runner.run(p,"careful",{policy=play});local b=runner.run(p,"careful",{policy=play})
            assert(a.status=="completed" and control.status=="completed");equal(a,b)
            days=days+a.totals.days-control.totals.days
        end
        print("  practice vs skip: mean days "..string.format("%+.2f",days/12).." across 12 seeds")
    end)
    test("courier remembers help and practice across an ending",function()
        local p=model.new(7);command(p,"depart");p.run.target=2;courier.arrive(p)
        assert(p.run.pending.id=="courier_intro");command(p,"choice",{id="share"})
        p.run.target=3;courier.arrive(p);assert(p.run.road_story:find("shared"))
        command(p,"return");assert(p.profile.courier.helped);command(p,"new");command(p,"depart")
        p.run.target=3;courier.arrive(p);assert(p.run.road_story:find("earlier journey"));valid(p)
        local old=model.new(8);old.run.courier_rules=nil;old.run.target=2;courier.arrive(old);assert(not old.run.pending)
    end)
end
