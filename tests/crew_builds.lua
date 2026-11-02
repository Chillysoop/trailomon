local c=require "simulation.wagon_combat"
local old=require "simulation.wagon_combat_v1"
local content=require "content.ambush"
local util=require "simulation.util"
local practice=require "simulation.wagon_practice"
local model=require "simulation.expedition"
local save=require "services.save"
local controller=require "services.ambush_controller"
local function unit(s,id) return assert(c.unit(s,id)) end
local function quiet(s) for _,u in ipairs(s.units) do u.attack_left=50;u.focus=0 end end
local function valid(s) local ok,why=c.validate(s);assert(ok,why) end
local function drill()
    local p=model.new(1848);assert(model.command(p,"depart"));p.run.mode="landmark";p.run.target=3;p.run.progress=p.run.distance;return p
end
return function(test,equal)
    test("v1 ambush checkpoints keep their exact original resolver",function()
        local a=old.new("rush",22);old.start(a);old.step(a,32)
        local b=util.copy(a);assert(c.validate(b));c.step(b,1800);old.step(a,1800);equal(a,b)
    end)
    test("six kits can swap only before combat and gear transfers without duplication",function()
        local s=c.new();assert(c.replace(s,"moss","ripple"));assert(not c.replace(s,"ember","ripple"))
        assert(c.equip(s,"ripple","padded_trace"));assert(c.equip(s,"ember","padded_trace"));assert(unit(s,"ripple").item=="")
        assert(not c.equip(s,"caller","dry_wrap"));c.start(s)
        assert(not c.replace(s,"ripple","flint") and not c.equip(s,"ember","dry_wrap"));valid(s)
    end)
    test("Reedskipper interrupts and redirects exactly one basic then advances its clock",function()
        local s=c.new("guard",1,{"ripple","ember","lumen"});c.move(s,"ripple",4);c.start(s);quiet(s)
        local r=unit(s,"raider");unit(s,"ripple").focus=44;c.step(s)
        assert(c.has(r,"lure") and c.has(r,"stun") and c.target(s,r).id=="ripple")
        c.step(s,6);r.attack_left=0;local left=unit(s,"ripple").attack_left;c.step(s)
        assert(not c.has(r,"lure") and unit(s,"ripple").stats.intercepts==1)
        assert(unit(s,"ripple").attack_left<=left-5 and unit(s,"ember").stats.reactions==1);valid(s)
    end)
    test("Loamling exposes once per opening and release rope changes basic hits",function()
        local s=c.new("control");c.start(s);quiet(s)
        local p=unit(s,"pip");p.focus=p.cost-1;p.attack_left=1;c.step(s)
        assert(c.has(unit(s,"raider"),"expose") and p.stats.openings==1 and p.stats.item_procs==1)
        p.attack_left=1;c.step(s);assert(p.stats.openings==1 and p.stats.item_procs==2);valid(s)
    end)
    test("Slatewhorl supports companions only and shield Focus is bounded",function()
        local s=c.new("control");c.start(s);quiet(s);local f=unit(s,"flint")
        f.focus=f.cost-1;c.step(s);assert(unit(s,"ripple").shield==22 and s.wagon.shield==0)
        c.move(s,"flint",1);f.position=1;unit(s,"ripple").position=4;unit(s,"pip").position=3
        c.shield(s,f,100,"flint");quiet(s);local r=unit(s,"raider");r.focus=r.cost-1;r.attack_left=1
        c.step(s);assert(f.focus==5);valid(s)
    end)
    test("equipment trades attack and defense for bounded defensive Focus",function()
        local s=c.new();c.equip(s,"moss","padded_trace");c.equip(s,"ember","dry_wrap");c.start(s);quiet(s)
        assert(c.defense(unit(s,"moss"))==118 and c.interval(unit(s,"moss"))==24)
        local r=unit(s,"raider");r.focus=r.cost-1;r.attack_left=1;c.step(s)
        assert(unit(s,"moss").stats.item_procs==1 and unit(s,"moss").focus==4)
        c.shield(s,unit(s,"ember"),40,"moss");c.step(s,3);assert(unit(s,"ember").stats.item_procs==1);valid(s)
    end)
    test("limited supplies neither revive nor waste charges and survive replay",function()
        local s=c.new();assert(not c.supply(s,"repairs"));c.start(s);assert(not c.supply(s,"medicine"))
        s.wagon.hp=85;unit(s,"moss").hp=0;unit(s,"ember").hp=70
        assert(c.supply(s,"repairs") and s.wagon.hp==100 and s.supplies.repairs==0)
        assert(c.supply(s,"medicine") and unit(s,"ember").hp==82 and unit(s,"moss").hp==0)
        assert(not c.supply(s,"medicine"));local copy=util.copy(s);c.step(s,1800);c.step(copy,1800);equal(s,copy);valid(s)
    end)
    test("practice pays exactly once and keeps health cargo wagon supplies unchanged",function()
        local p=drill();p.run.crew[1].name="Fern";local before=util.copy(p);local r=assert(practice.record(p.run));p=assert(practice.commit(p,r))
        assert(c.kit(r.battle,r.battle.units[1].id).name=="Fern")
        equal(p.run.crew,before.run.crew);c.start(r.battle);p=assert(practice.commit(p,r));assert(save.validate(p));assert(not p.run.aim_journey.fought)
        for i,v in ipairs(p.run.crew) do assert(v.stamina==before.run.crew[i].stamina-6 and v.condition==before.run.crew[i].condition) end
        local paid=util.copy(p.run.crew);r.battle.wagon.hp=20;c.supply(r.battle,"repairs");c.step(r.battle,1800)
        p=assert(practice.commit(p,r));equal(p.run.crew,paid);assert(p.run.aim_journey.fought)
        for _,key in ipairs({"wagon","cargo","food","medicine","repairs","day","coins"}) do equal(p.run[key],before.run[key]) end
        assert(not practice.commit(p,{battle=c.new("guard",1848,nil,"mara"),speed=1,carry=0}));assert(save.validate(p))
    end)
    test("practice rejects exhausted crews, foreign gear and cross-mode replay",function()
        local p=drill();local r=assert(practice.record(p.run));p.run.crew[1].stamina=5;c.start(r.battle)
        local before=util.copy(p);assert(not practice.commit(p,r));equal(p,before)
        p=drill();r=assert(practice.record(p.run));r.battle.units[1].item="dry_wrap";assert(not practice.commit(p,r))
        r=assert(practice.record(p.run));p.run.mode="stopped";assert(not practice.commit(p,r))
    end)
    test("practice controller persists payment atomically and resumes paused",function()
        local ui={snapshot=drill(),redraw=function() end,has_focus=true};ui.open_page=function(page) ui.page=page end
        local persisted;local writer=function(p) assert(save.validate(p));persisted=util.copy(p);return true end
        assert(controller.open_practice(ui,writer));assert(controller.command(ui,"start"));local energy=ui.snapshot.run.crew[1].stamina
        controller.update(ui,0.25);controller.pause(ui);assert(controller.open_practice(ui,writer));assert(ui.ambush.paused)
        assert(ui.snapshot.run.crew[1].stamina==energy);assert(not controller.command(ui,"new"));assert(not controller.command(ui,"replace",{id="moss",replacement="ember"}))
        controller.command(ui,"retreat");equal(ui.snapshot,persisted)
        ui={snapshot=drill(),redraw=function() end,open_page=function() end};local before=util.copy(ui.snapshot)
        assert(controller.open_practice(ui,function() return false,"Disk full" end));controller.command(ui,"start")
        assert(ui.ambush.paused and ui.ambush.error);equal(ui.snapshot,before)
    end)
    test("all three-species builds finish and checkpoint identically",function()
        local wins=0
        for a=1,4 do for b=a+1,5 do for d=b+1,6 do
            for _,seed in ipairs({1,7,23}) do
                local s=c.new("guard",seed,{content.crew[a],content.crew[b],content.crew[d]});c.start(s);c.step(s,37)
                local restored=util.copy(s);c.step(s,1800);while restored.phase=="fight" do c.step(restored);valid(restored) end
                equal(s,restored);assert(s.phase=="result");if s.result=="victory" then wins=wins+1 end
            end
        end end end
        assert(wins>=6);print("  60 crew/seed comparisons: "..wins.." wins; exact replay")
    end)
end
