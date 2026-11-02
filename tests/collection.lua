local model=require "simulation.expedition"
local collection=require "simulation.collection"
local combat=require "simulation.wagon_combat"
local save=require "services.save"
local util=require "simulation.util"
local M={}
local function cmd(p,id,arg) local ok,why=model.command(p,id,arg);assert(ok,why);local good,reason=save.validate(p);assert(good,reason) end
function M.four()
    local p=model.new(1848,"discovery")
    collection.collect(p,"loamling");collection.collect(p,"brindlehorn");collection.collect(p,"bellmoth")
    return p
end
return function(test,equal)
    test("collection owns separate individuals and four active slots without crew points",function()
        local p=M.four();assert(#p.profile.collection==4 and #p.run.crew==4)
        assert(p.run.crew[1].uid~=p.run.crew[3].uid)
        local c,traveling=collection.collect(p,"slatewhorl");assert(not traveling and #p.run.crew==4 and #p.profile.collection==5)
        local before=util.copy(p);assert(not model.command(p,"collect_select",{uid=c.uid}));equal(p,before)
        cmd(p,"buy_work_item",{item="padded_trace"});cmd(p,"equip_work_item",{member=3,item="padded_trace"})
        local id=p.run.crew[3].uid;p.run.crew[3].name="Other Moss"
        cmd(p,"collect_select",{uid=id});assert(collection.find(p.profile,id).name=="Other Moss" and not collection.find(p.profile,id).work_item)
        cmd(p,"collect_select",{uid=c.uid});assert(p.run.work_items.padded_trace and #p.run.crew==4)
        cmd(p,"depart");before=util.copy(p);assert(not model.command(p,"collect_select",{uid=id}));equal(p,before)
    end)
    test("full-party invitations collect duplicates, charge exact food, and do not inflate upkeep",function()
        local p=M.four();cmd(p,"depart");local s=p.run
        assert(model.debug(p,"event","discover_loamling"))
        local preview=model.events.recruit_preview(s,model.events.by_id.discover_loamling.choices[1])
        assert(preview.reserve and preview.meals_after==preview.meals_before)
        local food=s.food;cmd(p,"choice",{id="invite"})
        assert(#p.profile.collection==5 and #s.crew==4 and s.food==food-4)
        local before=util.copy(p);assert(not model.command(p,"choice",{id="invite"}));equal(p,before)
        assert(model.debug(p,"event","slate_return"));s.food=3;before=util.copy(p)
        assert(not model.command(p,"choice",{id="invite"}));equal(p,before)
        cmd(p,"choice",{id="part"});cmd(p,"return");local count=#p.profile.collection
        assert(not model.finish(p,"returned","duplicate"));assert(#p.profile.collection==count)
        cmd(p,"new");assert(#p.run.crew==4 and #p.profile.collection==5)
    end)
    test("collection retains 1000 individuals and rejects duplicate or foreign identities",function()
        local p=M.four()
        for i=5,1000 do collection.collect(p,model.species.order[(i-1)%6+1]) end
        assert(#p.profile.collection==1000 and save.validate(p))
        local fake=combat.new();fake.units[1]=util.copy(fake.units[4]);fake.units[1].id="raider_2";fake.units[1].side="crew"
        assert(not combat.validate(fake))
        local q=util.copy(p);assert(save.validate(q));equal(p,q)
        q.profile.collection[7].uid=q.profile.collection[8].uid;assert(not save.validate(q))
        q=util.copy(p);q.run.crew[2].uid=q.run.crew[1].uid;assert(not save.validate(q))
        q=util.copy(p);q.run.crew[2].uid=999999;assert(not save.validate(q))
        q=util.copy(p);q.run.crew[5]=util.copy(q.profile.collection[5]);assert(not save.validate(q))
    end)
    test("four-member collection journeys finish and replay without stalls",function()
        local runner=require "tools.report.runner"
        for _,strategy in ipairs({"careful","fighter"}) do
            local p=M.four();local a=runner.run(p,strategy);local b=runner.run(p,strategy)
            assert(a.status=="completed");equal(a,b)
            assert(a.crew_minimum["brindlehorn#1"] and a.crew_minimum["brindlehorn#3"])
        end
    end)
    test("solo duplicate pairs and four-member crews record valid distinct departure crews",function()
        local p=M.four();cmd(p,"depart");assert(p.run.aim_journey.pair=="crew:bellmoth+brindlehorn+brindlehorn+loamling")
        assert(model.finish(p,"delivered","Fixture delivery"));assert(save.validate(p));cmd(p,"new")
        cmd(p,"collect_select",{uid=2});cmd(p,"collect_select",{uid=4});cmd(p,"depart")
        assert(p.run.aim_journey.pair=="crew:brindlehorn+brindlehorn")
        assert(model.finish(p,"delivered","Fixture delivery"));assert(p.profile.aims.completed.company and save.validate(p))
        p=model.new(8,"discovery");cmd(p,"depart");assert(p.run.aim_journey.pair=="crew:brindlehorn")
    end)
    test("old saves migrate names injuries habits and pending combat without rerolls",function()
        local p=require("tests.pre_collection_model").new(33)
        cmd(p,"depart");p.run.crew[1].name="Old friend";p.run.crew[1].stamina=41;p.run.crew[1].condition=57
        assert(model.debug(p,"event","scavengers"));cmd(p,"choice",{id="battle"});cmd(p,"road_start");cmd(p,"road_step",{ticks=25})
        local before=util.copy(p);collection.ensure(p);assert(save.validate(p))
        equal(p.run.wagon_battle,before.run.wagon_battle);equal(p.run.rng,before.run.rng)
        assert(p.run.crew[1].name=="Old friend" and p.run.crew[1].condition==57 and p.run.crew[1].stamina==35)
        local again=util.copy(p);collection.ensure(p);equal(p,again)
    end)
    test("four combatants including twins keep separate clocks damage costs and checkpoints",function()
        for _,kind in ipairs({"scavengers","territorial"}) do
            local p=M.four();cmd(p,"depart");p.run.crew[3].condition=51
            assert(model.debug(p,"event",kind));cmd(p,"choice",{id="battle"})
            local b=p.run.wagon_battle.battle;assert(#combat.crew(b)==4)
            assert(combat.unit(b,"moss").hp==116 and combat.unit(b,"moss_2").hp==59)
            cmd(p,"road_move",{id="moss_2",position=2});cmd(p,"road_start")
            local copy=util.copy(p)
            for i=1,180 do
                if p.run.wagon_battle.settled then break end
                cmd(p,"road_step",{ticks=10});cmd(copy,"road_step",{ticks=10});equal(p,copy)
            end
            assert(p.run.wagon_battle.settled)
            for _,c in ipairs(p.run.crew) do assert(c.stamina==94) end
            assert(combat.unit(p.run.wagon_battle.battle,"moss_2").stats.attacks>0)
            cmd(p,"road_continue");cmd(p,"return");assert(#p.profile.collection==4)
        end
    end)
    test("duplicate habits and fourth crew care target only the chosen individual",function()
        local p=M.four();p.run.crew[1].habit_days=3;p.run.crew[3].habit_days=3
        cmd(p,"habit",{species="brindlehorn",uid=p.run.crew[3].uid})
        assert(p.run.crew[3].habit and not p.run.crew[1].habit)
        cmd(p,"depart");p.run.crew[4].condition=20;cmd(p,"treat",{member=4});assert(p.run.crew[4].condition==75)
        cmd(p,"return");cmd(p,"new");assert(p.run.crew[3].habit and not p.run.crew[1].habit)
    end)
    test("collected species remain available to befriend on later expeditions",function()
        local p=M.four();cmd(p,"depart");cmd(p,"return");cmd(p,"new");cmd(p,"depart")
        local s=p.run;s.target=2;s.mode="landmark";s.progress=s.distance
        assert(require("simulation.discovery").invitation(p)=="brindlehorn")
        cmd(p,"meet_wild");cmd(p,"choice",{id="invite"});assert(#p.profile.collection==5)
        s.target=5;s.terrain="upland";assert(model.events.eligible(s,model.events.by_id.slate_tracks,p.profile))
    end)
    test("four-member practice preserves individual health and charges every member once",function()
        local p=M.four();cmd(p,"depart");local s=p.run;s.target=3;s.mode="landmark";s.progress=s.distance
        local practice=require "simulation.wagon_practice";local r=assert(practice.record(s));combat.start(r.battle)
        p=assert(practice.commit(p,r));combat.step(r.battle,1800);p=assert(practice.commit(p,r));assert(save.validate(p))
        for _,c in ipairs(p.run.crew) do assert(c.stamina==94 and c.condition==100) end
        local before=util.copy(p);p=assert(practice.commit(p,r));equal(p,before)
    end)
end
