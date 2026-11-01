local c=require "simulation.wagon_combat"
local util=require "simulation.util"
local controller=require "services.ambush_controller"
local persistence=require "services.ambush_save"
local function battle(preset,crew) local s=c.new(preset,1848,crew);assert(c.start(s));return s end
local function quiet(s)
    for _,u in ipairs(s.units) do u.attack_left=50;u.focus=0 end
end
local function unit(s,id) return assert(c.unit(s,id)) end
local function valid(s) local ok,why=c.validate(s);assert(ok,why) end
local function storage()
    local saved
    return {load=function() return util.copy(saved) end,write=function(record) assert(persistence.validate(record));saved=util.copy(record);return true end}
end
return function(test,equal)
    test("ambush has independent clocks, repeat abilities and contrasting plans",function()
        local guard=battle("guard");local rush=battle("rush")
        local one=util.copy(guard);c.step(guard,1800)
        while one.phase=="fight" do c.step(one);valid(one) end
        equal(guard,one);c.step(rush,1800)
        assert(guard.result=="victory" and rush.result=="victory")
        assert(rush.tick<guard.tick and guard.wagon.hp>rush.wagon.hp and rush.wagon.hp>0)
        for _,u in ipairs(guard.units) do if u.side=="crew" then assert(u.stats.casts>=2 and u.stats.attacks>=2) end end
        assert(unit(guard,"ember").stats.reactions>0 and unit(guard,"moss").stats.intercepts>0)
        assert(unit(rush,"moss").stats.intercepts==0)
        for _,k in pairs(c.kits) do assert(k.cost>=10 and k.interval>=5 and k.interval<=50) end
        valid(rush)
    end)
    test("formation swaps and fallen front open the corresponding wagon lane",function()
        local s=c.new();assert(c.move(s,"moss",3));assert(unit(s,"ember").position==1)
        assert(c.target(s,unit(s,"raider")).id=="ember")
        assert(c.move(s,"ember",2));assert(c.target(s,unit(s,"raider")).id=="wagon")
        assert(c.start(s));assert(not c.move(s,"moss",1))
        s=battle();unit(s,"moss").hp=0;c.step(s)
        assert(unit(s,"raider").target=="wagon" and unit(s,"moss").stats.attacks==0)
    end)
    test("defense halves damage at 100; shields absorb and cap without repairing",function()
        local s=battle();quiet(s);local moss=unit(s,"moss");local raider=unit(s,"raider")
        moss.shield=5;raider.attack_left=1;c.step(s)
        assert(moss.hp==moss.max_hp-3 and moss.shield==0 and moss.stats.absorbed==5)
        assert(s.wagon.hp==100 and unit(s,"ember").stats.reactions==1)
        s.wagon.hp=20;c.shield(s,s.wagon,500,"moss");assert(s.wagon.shield==100 and s.wagon.hp==20)
        moss.hp=0;c.shield(s,moss,10,"moss");assert(moss.hp==0 and moss.shield==0)
    end)
    test("effect source and duration survive checkpoints; stun suspends clocks",function()
        local s=battle();quiet(s);local caller=unit(s,"caller")
        c.effect(s,caller,"stun","lumen",1,14);c.step(s,5)
        local restored=util.copy(s);assert(caller.focus==0 and caller.attack_left==50)
        equal(caller.effects,{{kind="stun",source="lumen",value=1,until_tick=14}})
        c.step(s,9);c.step(restored,9);equal(s,restored)
        assert(not c.has(caller,"stun") and caller.focus==1 and caller.attack_left==49)
        valid(s)
    end)
    test("intercept reactions are attributed and bounded once per source per tick",function()
        local s=battle();quiet(s);local r=unit(s,"raider");r.attack_left=1;r.focus=r.cost-1
        c.step(s);assert(unit(s,"moss").stats.intercepts==2 and unit(s,"ember").stats.reactions==1)
        assert(unit(s,"ember").stats.damage>0 and r.stats.reactions==0)
        local t=battle();quiet(t);r=unit(t,"raider");r.attack_left=1
        c.effect(t,unit(t,"ember"),"stun","caller",1,15);c.step(t)
        assert(unit(t,"ember").stats.reactions==0)
    end)
    test("wagon failure wins a simultaneous final opponent knockout",function()
        local s=battle();quiet(s);s.wagon.hp=1;unit(s,"moss").hp=1;unit(s,"caller").hp=0
        local r=unit(s,"raider");r.hp=1;r.focus=r.cost-1;r.attack_left=1
        c.step(s);assert(s.wagon.hp==0 and r.hp==0 and s.result=="wagon_lost")
        local before=util.copy(s);c.step(s,100);assert(not c.retreat(s));equal(s,before);valid(s)
    end)
    test("KO cancels attacks, retreat and stalemate always terminate",function()
        local s=battle();quiet(s);local r=unit(s,"raider");r.hp=1;r.attack_left=1;unit(s,"moss").attack_left=1
        c.step(s);assert(r.hp==0 and r.stats.attacks==0)
        assert(c.retreat(s) and s.result=="retreated")
        s=battle();for _,u in ipairs(s.units) do if u.side=="crew" then u.hp=0 end end
        c.step(s);assert(s.result=="crew_down")
        s=battle();for _,u in ipairs(s.units) do c.effect(s,u,"stun",u.id,1,c.LIMIT+20) end
        c.step(s,c.LIMIT);assert(s.result=="stalemate" and s.tick==c.LIMIT);valid(s)
    end)
    test("solo and pair crews terminate and unsupported saves are rejected",function()
        for _,crew in ipairs({{"moss"},{"ember"},{"lumen"},{"ember","lumen"},{"moss","ember"}}) do
            local s=battle("guard",crew);c.step(s,c.LIMIT);assert(s.phase=="result");valid(s)
        end
        local s=battle();s.rules="future-version";assert(not c.validate(s))
        s=battle();s.units[1].effects={{kind="stun",source="missing",value=1,until_tick=20}};assert(not c.validate(s))
        s=battle();s.units[1].attack_left=0/0;assert(not c.validate(s))
        s=battle();s.units[2].position=s.units[1].position;assert(not c.validate(s))
        assert(not persistence.validate({battle=battle(),speed=1,carry=math.huge}))
    end)
    test("every live tick restores exactly including targets, clocks, RNG and effects",function()
        local s=battle()
        while s.phase=="fight" do
            local copy=util.copy(s);c.step(copy);c.step(s);equal(s,copy);valid(s)
        end
    end)
    test("playback pause fast reload and menus preserve simulation and expedition",function()
        local model=require "simulation.expedition";local journey=model.new(1848);local before=util.copy(journey)
        local function view()
            local ui={snapshot=journey,page="debug",has_focus=true,redraw=function() end}
            ui.open_page=function(page) ui.page=page end;controller.open(ui,storage());controller.command(ui,"start");return ui
        end
        local slow,fast=view(),view();controller.command(fast,"speed")
        for _=1,120 do controller.update(slow,1/30) end
        for _=1,120 do controller.update(fast,1/60) end
        equal(slow.ambush.battle,fast.ambush.battle)
        controller.update(slow,0.05);controller.pause(slow)
        local stopped=util.copy(slow.ambush.battle);local carry=slow.ambush.carry
        for _=1,30 do controller.update(slow,0.25) end;equal(slow.ambush.battle,stopped)
        controller.command(slow,"reload");assert(slow.ambush.paused and slow.ambush.carry==carry)
        equal(slow.ambush.battle,stopped);controller.command(slow,"pause")
        slow.page="journal";controller.update(slow,0.2);equal(slow.ambush.battle,stopped)
        slow.page="ambush";slow.has_focus=false;controller.update(slow,0.2);equal(slow.ambush.battle,stopped)
        slow.has_focus=true;controller.update(slow,0.05);assert(slow.ambush.battle.tick==stopped.tick+1)
        slow.ambush.storage.write=function() return false,"Disk full" end
        controller.command(slow,"speed");assert(slow.ambush.error and slow.ambush.paused)
        equal(journey,before)
    end)
end
