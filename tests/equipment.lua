local model=require "simulation.expedition"
local util=require "simulation.util"
local save=require "services.save"
local progression=require "simulation.progression"
local clarity=require "simulation.clarity"
return function(test,command,valid,equal)
    local function pack(p,id,member)
        command(p,"buy_work_item",{item=id})
        command(p,"equip_work_item",{item=id,member=member})
    end
    local function fight(p,kind,team)
        command(p,"depart");assert(model.debug(p,"event",kind));command(p,"choice",{id="battle"})
        command(p,"battle_start",{team=team or {1,2}})
    end
    test("work-item purchases and returns respect money, load and one-copy ownership",function()
        local p=model.new(1848);local weight=model.resources.weight(p.run);local coins=p.run.coins
        for _,id in ipairs(model.equipment.order) do command(p,"buy_work_item",{item=id}) end
        assert(model.resources.weight(p.run)==weight+9 and p.run.coins==coins-30)
        local before=util.copy(p);assert(not model.command(p,"buy_work_item",{item="dry_wrap"}));equal(p,before)
        command(p,"equip_work_item",{item="padded_trace",member=1})
        command(p,"sell_work_item",{item="padded_trace"})
        assert(not p.run.crew[1].work_item and model.resources.weight(p.run)==weight+5)
        p=model.new(1848);p.run.food=p.run.food+29;before=util.copy(p)
        assert(not model.command(p,"buy_work_item",{item="dry_wrap"}));equal(p,before)
        p=model.new(1848);p.run.coins=7;before=util.copy(p)
        assert(not model.command(p,"buy_work_item",{item="dry_wrap"}));equal(p,before)
        p=model.new(1848);pack(p,"dry_wrap",1);command(p,"depart");before=util.copy(p)
        assert(not model.command(p,"buy_work_item",{item="release_rope"}));equal(p,before)
        p.run.target=3;p.run.mode="landmark";command(p,"buy_work_item",{item="release_rope"})
        before=util.copy(p);assert(not model.command(p,"sell_work_item",{item="dry_wrap"}));equal(p,before)
    end)
    test("one slot transfers without duplication and swaps lock before any encounter",function()
        local p=model.new(1848);pack(p,"padded_trace",1);pack(p,"dry_wrap",2)
        local rng=util.copy(p.run.rng);local coins=p.run.coins;local weight=model.resources.weight(p.run)
        command(p,"equip_work_item",{item="padded_trace",member=2})
        assert(not p.run.crew[1].work_item and p.run.crew[2].work_item=="padded_trace")
        assert(p.run.work_items.dry_wrap and p.run.coins==coins and model.resources.weight(p.run)==weight)
        equal(p.run.rng,rng);assert(p.run.day==1)
        command(p,"equip_work_item",{member=2});assert(not p.run.crew[2].work_item)
        command(p,"depart");command(p,"resume")
        local before=util.copy(p);assert(not model.command(p,"equip_work_item",{item="dry_wrap",member=1}));equal(p,before)
        command(p,"pause");command(p,"equip_work_item",{item="dry_wrap",member=1})
        assert(model.debug(p,"event","scavengers"))
        for _,mode in ipairs({"event","combat_select","combat","combat_result","result"}) do
            p.run.mode=mode;before=util.copy(p)
            assert(not model.command(p,"equip_work_item",{member=1}));equal(p,before)
        end
    end)
    test("padded trace changes hurried haul cost and its actual readiness threshold",function()
        local p=model.new(1848);pack(p,"padded_trace",1);local plain=util.copy(p);plain.run.crew[1].work_item=nil
        for _,x in ipairs({p,plain}) do command(x,"depart");command(x,"policy",{key="pace",value="hurried"});command(x,"resume");command(x,"step") end
        assert(p.run.crew[1].stamina==plain.run.crew[1].stamina+3)
        assert(model.forecast(p.run).effort==8 and model.forecast(plain.run).effort==11)
        p.run.crew[1].stamina=8;plain.run.crew[1].stamina=8
        assert(model.resources.hauler(p.run) and not model.resources.hauler(plain.run))
        p.run.flags.river_crossed=true
        assert(clarity.next_duty(p.run).text:find("8 energy",1,true))
        p.run.pace="steady";assert(model.forecast(p.run).effort==7)
    end)
    test("padded trace absorbs one damaging approach hit and saves its spent state",function()
        local p=model.new(1848);pack(p,"padded_trace",1);fight(p,"scavengers")
        p.run.battle.intent={kind="rush",target=1,damage=20}
        local before=util.copy(p);model.combat.preview(p.run);equal(p,before)
        command(p,"battle_step");assert(p.run.crew[1].condition==100 and p.run.battle.item_used.padded_trace)
        p.run.battle.intent={kind="heavy",target=1,damage=20}
        local restored=util.copy(p);valid(restored)
        command(p,"battle_step");command(restored,"battle_step");equal(p,restored)
        assert(p.run.crew[1].condition==86,"Armor must not refresh on load or every exchange")
        p=model.new(1848);pack(p,"padded_trace",2);fight(p,"scavengers")
        p.run.battle.intent={kind="rush",target=1,damage=20};command(p,"battle_step")
        assert(p.run.crew[1].condition==94 and not p.run.battle.item_used,"Wagon trace cannot protect the approach")
    end)
    test("release rope preserves crossing supplies but never removes the other consequences",function()
        local p=model.new(1848);pack(p,"release_rope",1);command(p,"depart")
        p.run.mode="landmark";p.run.target=4;p.run.river_roll=0;p.run.rainfall=6
        local plain=util.copy(p);plain.run.crew[1].work_item=nil
        command(p,"river",{method="anchor"});command(plain,"river",{method="anchor"})
        assert(p.run.food==plain.run.food+4 and p.run.cargo==plain.run.cargo+9)
        assert(p.run.wagon==plain.run.wagon and p.run.crew[1].condition==plain.run.crew[1].condition)
        assert(p.run.day==plain.run.day and p.run.crew[1].stamina==plain.run.crew[1].stamina)
    end)
    test("rope retreat benefit needs the wearer in combat and charges only once",function()
        local p=model.new(1848);pack(p,"release_rope",2);fight(p,"scavengers")
        assert(model.combat.withdraw_text("scavengers",p.run):find("4 provisions",1,true))
        command(p,"withdraw");assert(p.run.battle.result.food==-4 and p.run.battle.result.cargo==-4)
        local before=util.copy(p);assert(not model.command(p,"withdraw"));equal(p,before)
        p=model.new(1848);pack(p,"release_rope",2);fight(p,"scavengers",{1});command(p,"withdraw")
        assert(p.run.battle.result.food==-8 and p.run.battle.result.cargo==-8)
        p=model.new(1848);pack(p,"release_rope",2);fight(p,"territorial");command(p,"withdraw")
        assert(p.run.battle.result.days==1,"Rope must not erase the guardian detour")
    end)
    test("dry wrap needs rainy meals for recovery and preserves Bellmoth shimmer",function()
        local p=model.new(1848);pack(p,"dry_wrap",2);command(p,"depart")
        p.run.crew[2].stamina=50;p.run.rng.weather=1
        local plain=util.copy(p);plain.run.crew[2].work_item=nil
        command(p,"rest");command(plain,"rest")
        assert(p.run.weather=="rain" and p.run.crew[2].stamina==plain.run.crew[2].stamina+3)
        p.run.food=0;p.run.rng.weather=1;p.run.crew[2].stamina=50
        plain=util.copy(p);plain.run.crew[2].work_item=nil
        command(p,"rest");command(plain,"rest");assert(p.run.crew[2].stamina==plain.run.crew[2].stamina)
        p=model.new(1848);p.run.crew[2]=progression.companion("bellmoth");pack(p,"dry_wrap",2)
        fight(p,"scavengers",{2});p.run.weather="rain";p.run.battle.intent={kind="heavy",target=2,damage=20}
        plain=util.copy(p);plain.run.crew[2].work_item=nil
        assert(model.combat.ability_text(p.run,"bellmoth",p.run.crew[2]):find("16 harm",1,true))
        command(p,"battle_step");command(plain,"battle_step")
        assert(p.run.crew[2].condition==plain.run.crew[2].condition+8)
        assert(p.run.battle.history[1].cover==16 and plain.run.battle.history[1].cover==8)
    end)
    test("work items keep old saves valid and cannot leak into the next expedition",function()
        local old=model.new(1848);old.run.work_items=nil;valid(old)
        local p=model.new(1848);pack(p,"padded_trace",1);command(p,"depart");command(p,"return")
        assert(not p.profile.roster.brindlehorn.work_item)
        command(p,"new",{seed=1848});assert(not p.run.work_items and not p.run.crew[1].work_item and p.run.coins==50)
        p=model.new(1848);pack(p,"padded_trace",1)
        local bad=util.copy(p);bad.run.crew[2].work_item="padded_trace";assert(not save.validate(bad))
        bad=util.copy(p);bad.run.work_items.padded_trace=nil;assert(not save.validate(bad))
        bad=util.copy(p);bad.run.work_items.fake=true;assert(not save.validate(bad))
        bad=util.copy(p);bad.run.work_items.padded_trace=2;assert(not save.validate(bad))
        bad=util.copy(p);bad.run.work_items="broken";assert(not save.validate(bad))
        fight(p,"territorial");p.run.battle.item_used={dry_wrap=true};assert(not save.validate(p))
    end)
end
