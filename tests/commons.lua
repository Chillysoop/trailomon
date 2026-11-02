local model=require "simulation.expedition"
local collection=require "simulation.collection"
local save=require "services.save"
local util=require "simulation.util"
local content=require "content.commons"
local function cmd(p,id,arg) local ok,why=model.command(p,id,arg);assert(ok,why);local valid,reason=save.validate(p);assert(valid,reason) end
local function meet(p,id)
    assert(model.debug(p,"event",content.defs[id].event));cmd(p,"choice",{id="invite"})
    return p.profile.collection[#p.profile.collection]
end
return function(test,equal)
    test("Commons starter changes reset residents without leaving a false homecoming",function()
        local p=model.new(77,"discovery");cmd(p,"starter",{species="reedskipper"})
        assert(not p.profile.commons_first.brindlehorn and p.profile.commons_first.reedskipper==1)
        assert(p.run.crew[1].origin.kind=="known" and p.run.crew[1].home_seen)
    end)
    test("waybed encounters settle once for the visible food cost without extra days",function()
        for _,id in ipairs({"loamling","bellmoth"}) do
            local p=model.new(77,"discovery");cmd(p,"depart")
            assert(model.debug(p,"event",content.defs[id].event))
            local before=util.copy(p);cmd(p,"choice",{id="invite"});local c=p.profile.collection[#p.profile.collection]
            assert(p.run.food==before.run.food-4 and p.run.day==before.run.day)
            assert(c.origin.event==content.defs[id].event and c.origin.day==p.run.day and c.origin.terrain==p.run.terrain)
            assert(c.origin.journey==1 and c.origin.target==p.run.target and not c.home_seen)
            assert(not p.profile.commons_first[id])
            equal(p.run.rng,before.run.rng)
            assert(p.run.log[#p.run.log].text:find(model.events.by_id[content.defs[id].event].choices[1].settle,1,true))
            before=util.copy(p);assert(not model.command(p,"choice",{id="invite"}));equal(p,before)
        end
    end)
    test("unaffordable waybeds and leaving wildlife do not create ownership or origins",function()
        local p=model.new(11,"discovery");cmd(p,"depart");assert(model.debug(p,"event","discover_bellmoth"));p.run.food=3
        local before=util.copy(p);assert(not model.command(p,"choice",{id="invite"}));equal(p,before)
        cmd(p,"choice",{id="pass"});assert(#p.profile.collection==1 and not p.profile.commons_first.bellmoth)
    end)
    test("return escorts keep full-party collecting free of active food upkeep or swaps",function()
        local p=model.new(77,"discovery");collection.collect(p,"loamling");collection.collect(p,"bellmoth");collection.collect(p,"reedskipper")
        cmd(p,"depart");local meals=model.resources.daily_food(p.run);local c=meet(p,"slatewhorl")
        assert(c.home_seen and p.profile.commons_first.slatewhorl==c.uid and #p.run.crew==4)
        assert(model.resources.daily_food(p.run)==meals)
        local before=util.copy(p);assert(not model.command(p,"collect_select",{uid=c.uid}));equal(p,before)
    end)
    test("homecomings survive every ending and duplicates retain their own meeting",function()
        for _,outcome in ipairs({"delivered","late","returned","rescued"}) do
            local p=model.new(11,"discovery");cmd(p,"depart");local a=meet(p,"loamling");local origin=util.copy(a.origin)
            p.run.day=4;local b=meet(p,"loamling");assert(a.uid~=b.uid and b.origin.day==4)
            assert(model.finish(p,outcome,"Fixture return"));assert(save.validate(p))
            equal(collection.find(p.profile,a.uid).origin,origin)
            assert(p.profile.commons_first.loamling==a.uid and collection.find(p.profile,b.uid).home_seen)
            local before=util.copy(p);assert(not model.finish(p,outcome,"Duplicate return"));equal(p,before)
            cmd(p,"new");assert(p.run.crew[2].origin.day==origin.day and p.run.crew[3].origin.day==4)
        end
    end)
    test("old collection saves gain honest unknown origins without changing live combat",function()
        local p=model.new(8);cmd(p,"depart");assert(model.debug(p,"event","scavengers"));cmd(p,"choice",{id="battle"});cmd(p,"road_start");cmd(p,"road_step",{ticks=25})
        p.profile.commons_first=nil
        for _,list in ipairs({p.profile.collection,p.run.crew,p.profile.roster}) do for _,c in pairs(list) do c.origin=nil;c.home_seen=nil end end
        assert(save.validate(p));local before=util.copy(p);collection.ensure(p);assert(save.validate(p))
        equal(p.run.wagon_battle,before.run.wagon_battle);equal(p.run.rng,before.run.rng)
        for _,c in ipairs(p.run.crew) do assert(c.origin.kind=="known" and not c.origin.event) end
        before=util.copy(p);collection.ensure(p);equal(p,before)
    end)
    test("malformed origins and impossible homecoming references are rejected",function()
        local p=model.new(8,"discovery");cmd(p,"depart");meet(p,"loamling");cmd(p,"return")
        for _,field in ipairs({"day","target","journey","event","terrain","kind"}) do
            local q=util.copy(p);q.profile.collection[2].origin[field]=field=="day" and 33 or false;assert(not save.validate(q),field)
        end
        local q=util.copy(p);q.profile.commons_first.loamling=1;assert(not save.validate(q))
        q=util.copy(p);q.profile.collection[2].home_seen="yes";assert(not save.validate(q))
        q=util.copy(p);q.profile.collection[2].home_seen=false;assert(not save.validate(q))
    end)
    test("all six resident stories share valid recruitment definitions",function()
        local p=model.new(8,"discovery");cmd(p,"depart")
        for _,id in ipairs(model.species.order) do
            local def=content.defs[id];local event=model.events.by_id[def.event]
            assert(event.choices[1].recruit==id and #def.arrival>20 and #def.bed>4)
            local c=meet(p,id);assert(c.origin.event==def.event)
        end
        cmd(p,"return");for _,id in ipairs(model.species.order) do assert(p.profile.commons_first[id]) end
    end)
end
