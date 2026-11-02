local model=require "simulation.expedition"
local road=require "simulation.wagon_road"
local combat=require "simulation.wagon_combat"
local util=require "simulation.util"
local save=require "services.save"
local controller=require "services.ambush_controller"
local function valid(p) local ok,why=save.validate(p);assert(ok,why) end
local function cmd(p,id,arg) local ok,why=model.command(p,id,arg);assert(ok,id..": "..tostring(why));valid(p) end
local function setup(kind,mode)
    local p=model.new(73,mode);cmd(p,"depart")
    assert(model.debug(p,"event",kind or "scavengers"));cmd(p,"choice",{id="battle"});return p
end
local function finish(p)
    if p.run.wagon_battle.battle.phase=="setup" then cmd(p,"road_start") end
    for _=1,180 do
        if p.run.wagon_battle.battle.phase=="result" then return end
        cmd(p,"road_step",{ticks=10})
    end
    error("Road combat stalled")
end
local function ui(p,writer)
    local self={snapshot=p,has_focus=true,redraw=function() end,open_page=function() end}
    assert(controller.open_road(self,writer));return self
end
return function(test,equal)
    test("new road fights use real HP wagon gear and at most one carried supply",function()
        local p=model.new(73);cmd(p,"depart");local s=p.run
        s.wagon=62.5;s.crew[1].condition=42.5;s.repairs=0
        s.work_items={padded_trace=true};s.food=70;s.crew[1].work_item="padded_trace"
        assert(model.debug(p,"event","scavengers"));cmd(p,"choice",{id="battle"})
        local b=s.wagon_battle.battle
        assert(b.wagon.hp==62 and b.supplies.repairs==0 and b.supplies.medicine==1)
        assert(b.units[1].hp==49 and b.units[1].item=="padded_trace")
        local before=util.copy(p);assert(not model.command(p,"road_equip",{id="moss",item="dry_wrap"}));equal(p,before)
        assert(not model.command(p,"rest"));equal(p,before)
        cmd(p,"road_move",{id="moss",position=3});cmd(p,"battle_back")
        assert(s.mode=="event" and s.wagon==62.5 and s.crew[1].condition==42.5)
    end)
    test("setup and pre-action clocks can return without reroll payment or aim loss",function()
        local p=setup();local original=util.copy(p.run.wagon_battle.battle)
        local rng=p.run.rng.combat;local energy=p.run.crew[1].stamina
        cmd(p,"road_start");cmd(p,"road_step",{ticks=1});assert(road.can_back(p.run))
        cmd(p,"battle_back");assert(p.run.rng.combat==rng and p.run.crew[1].stamina==energy)
        cmd(p,"choice",{id="battle"});equal(p.run.wagon_battle.battle,original)
        cmd(p,"road_start");cmd(p,"road_step",{ticks=25})
        assert(not road.can_back(p.run) and p.run.crew[1].stamina==energy-6)
        local before=util.copy(p);assert(not model.command(p,"battle_back"));equal(p,before)
    end)
    test("road supplies spend once and settlement survives replay and repeated acknowledgement",function()
        local p=setup();p.run.crew[1].condition=50
        -- Re-enter to map the wounded condition before combat.
        p.run.wagon_battle=nil;p.run.mode="event";p.run.encounter=nil;cmd(p,"choice",{id="battle"})
        cmd(p,"road_start");cmd(p,"road_supply",{id="medicine"})
        assert(p.run.medicine==1 and p.run.wagon_battle.charged)
        local before=util.copy(p);assert(not model.command(p,"road_supply",{id="medicine"}));equal(p,before)
        local copy=util.copy(p);finish(p);finish(copy);equal(p,copy)
        local settled=util.copy(p);assert(road.apply(p,util.copy(p.run.wagon_battle)));equal(p,settled)
        cmd(p,"road_continue");local final=util.copy(p)
        assert(not model.command(p,"road_continue"));equal(p,final)
    end)
    test("empty exhausted and disabled wagon encounters always allow withdrawal",function()
        for _,kind in ipairs({"scavengers","territorial"}) do
            local p=model.new(7,"discovery");cmd(p,"depart");local s=p.run
            s.crew[1].stamina=0;s.crew[1].condition=0;s.repairs=0;s.medicine=0;s.food=0;s.wagon=0
            assert(model.debug(p,"event",kind));cmd(p,"choice",{id="battle"})
            local before=util.copy(p);assert(not model.command(p,"road_start"));equal(p,before)
            cmd(p,"withdraw");assert(s.wagon_battle.settled and s.crew[1].stamina>=0)
            cmd(p,"road_continue");assert(s.mode=="stopped")
        end
    end)
    test("road defeat charges declared retreat cost once without double wagon and cargo hits",function()
        local p=setup();local s=p.run;cmd(p,"battle_back");s.wagon=1;cmd(p,"choice",{id="battle"})
        cmd(p,"road_move",{id="moss",position=4})
        finish(p);assert(s.wagon_battle.battle.result=="wagon_lost")
        assert(s.wagon==0 and s.cargo==92 and s.food==82)
        assert(s.wagon_battle.receipt.cargo==-8)
        local copy=util.copy(p);assert(road.apply(p,s.wagon_battle));equal(p,copy)
    end)
    test("road speed partial ticks focus loss and reload settle identically",function()
        local function run(speed,reload)
            local self=ui(setup(),function(p) valid(p);return true end)
            if speed==2 then controller.command(self,"speed") end
            controller.command(self,"start")
            for i=1,4000 do
                controller.update(self,0.033)
                if i%19==0 and reload then
                    controller.pause(self);local frozen=util.copy(self.snapshot)
                    self.has_focus=false;controller.update(self,999);equal(self.snapshot,frozen);self.has_focus=true
                    controller.command(self,"reload");assert(self.ambush.paused)
                    if self.ambush.battle.phase=="fight" then controller.command(self,"pause") end
                end
                if self.ambush.battle.phase=="result" then return self.snapshot.run.wagon_battle end
            end
            error("Playback stalled")
        end
        local a,b=run(1,false),run(2,true);equal(a.battle,b.battle);equal(a.receipt,b.receipt)
    end)
    test("terminal detours clear road battle and commit the journey only once",function()
        local p=setup("territorial");cmd(p,"battle_back");p.run.day=31;cmd(p,"choice",{id="battle"})
        cmd(p,"withdraw");assert(p.run.mode=="result" and not p.run.wagon_battle)
        local final=util.copy(p);assert(not model.command(p,"road_continue"));equal(p,final)
        cmd(p,"new");assert(p.run.road_combat_rules==road.RULES)
    end)
    test("ending a journey during road combat cannot discard injuries or fatigue",function()
        local p=setup();cmd(p,"road_start");cmd(p,"road_step",{ticks=35})
        local b=p.run.wagon_battle.battle;local u=combat.unit(b,"moss")
        assert(u.hp<u.max_hp);local expected=u.hp/u.max_hp*100
        cmd(p,"return");assert(p.run.mode=="result" and not p.run.wagon_battle)
        assert(math.abs(p.run.crew[1].condition-expected)<0.00001)
        assert(p.run.crew[1].stamina==94)
        local final=util.copy(p);assert(not model.command(p,"return"));equal(p,final)
    end)
    test("one two and three companions survive save boundaries in both depot modes",function()
        for _,mode in ipairs({"classic","discovery"}) do for n=1,3 do for _,kind in ipairs({"scavengers","territorial"}) do
            local p=model.new(19,mode);cmd(p,"depart")
            local ids={"brindlehorn","loamling","bellmoth"};p.run.crew={}
            for i=1,n do p.run.crew[i]=require("simulation.progression").companion(ids[i]) end
            require("simulation.collection").ensure(p)
            assert(model.debug(p,"event",kind));cmd(p,"choice",{id="battle"});cmd(p,"road_start")
            while p.run.wagon_battle.battle.phase=="fight" do
                local copy=util.copy(p);cmd(copy,"road_step",{ticks=10});cmd(p,"road_step",{ticks=10});equal(p,copy)
            end
            cmd(p,"road_continue");assert(p.run.mode=="stopped")
        end end end
    end)
    test("unready travelers sit out without fatigue or condition damage",function()
        local p=setup();cmd(p,"battle_back");p.run.crew[2].stamina=5
        cmd(p,"choice",{id="battle"});finish(p)
        assert(p.run.crew[2].stamina==5 and p.run.crew[2].condition==100)
        assert(p.run.wagon_battle.receipt.crew.pip.energy==0)
    end)
    test("road corrupt accounting and unknown rules are rejected",function()
        local p=setup()
        local edits={function(s) s.road_combat_rules="future" end,function(s) s.wagon_battle.initial.crew.moss.stamina=5 end,
            function(s) s.wagon_battle.battle.supplies.repairs=0 end,function(s) s.medicine=s.medicine-1 end,
            function(s) s.wagon_battle.battle.scenario="mara" end,function(s) s.wagon_battle.settled=true end,
            function(s) s.mode="stopped" end,function(s) s.wagon_battle=nil end}
        for _,edit in ipairs(edits) do local bad=util.copy(p);edit(bad.run);assert(not save.validate(bad)) end
    end)
    test("failed road saves pause without charging until a successful retry",function()
        local p=setup();local original=util.copy(p);local allow=false;local writes=0
        local self=ui(p,function(candidate) valid(candidate);writes=writes+1;return allow,"disk full" end)
        assert(controller.command(self,"start"));assert(self.ambush.error and self.ambush.paused);equal(self.snapshot,original)
        allow=true;assert(controller.command(self,"reload"));assert(self.ambush.battle.phase=="setup")
        assert(controller.command(self,"start"))
        for _=1,20 do controller.update(self,0.1) end
        assert(self.snapshot.run.wagon_battle.charged and self.snapshot.run.crew[1].stamina==94)
        controller.pause(self);local saved=util.copy(self.snapshot);controller.pause(self);equal(self.snapshot,saved)
        local resumed=ui(util.copy(saved),function(candidate) valid(candidate);return true end)
        assert(resumed.ambush.paused and writes>0)
        local tick=resumed.ambush.battle.tick;controller.update(resumed,999);assert(resumed.ambush.battle.tick==tick)
    end)
    test("attack lunges and ability lifts are bounded reversible and disabled by reduced motion",function()
        local b=combat.new();combat.start(b);local u=b.units[1]
        b.tick=10;b.events={{tick=9,kind="attack",source=u.id,target="raider",value=1},{tick=9,kind="cast",source=u.id,target="",value=0}}
        local before=util.copy(b);local view=require "presentation.ambush"
        local x,y=view.motion(b,u,0.05,true);assert(x>0 and x<=8 and y>0 and y<=6)
        local a,z=view.motion(b,u,0,false);assert(a==0 and z==0);equal(b,before)
        b.events[1].source="raider";x=view.motion(b,combat.unit(b,"raider"),0.05,true);assert(x<0 and x>=-8)
        b.tick=20;x,y=view.motion(b,u,0,true);assert(x==0 and y==0)
    end)
    test("fresh classic and Discovery full journeys remain deterministic and peaceful routes avoid combat",function()
        local runner=require "tools.report.runner"
        for _,mode in ipairs({"classic","discovery"}) do for _,strategy in ipairs({"careful","peaceful","fighter"}) do for seed=1,8 do
            local p=model.new(seed,mode);local r,final=runner.run(p,strategy)
            assert(r.status=="completed",r.failure and r.failure.message)
            local again,copy=runner.run(p,strategy);equal(final,copy)
            if strategy=="peaceful" then assert((r.totals.combat_seconds or 0)==0) end
            assert(r.actions<250);valid(final)
        end end end
    end)
end
