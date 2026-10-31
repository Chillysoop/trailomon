local model=require "simulation.expedition"
local util=require "simulation.util"
local progression=require "simulation.progression"
local save=require "services.save"
return function(test,command,valid,equal)
    local function setup(ids)
        local p=model.new(1848);command(p,"depart")
        p.run.crew={}
        for _,id in ipairs(ids or {"bellmoth"}) do p.run.crew[#p.run.crew+1]=progression.companion(id) end
        assert(model.debug(p,"event","guardian_pattern"));valid(p)
        command(p,"choice",{id="battle"})
        return p
    end
    test("guardian experiment has four exact readable stages and checkpoint equivalence",function()
        local p=setup();command(p,"battle_start",{team={1}})
        local rng=p.run.rng.combat
        local expected={{"rush","cargo",14},{"warning",1,0},{"heavy",1,20},{"heavy","cargo",20}}
        for round,stage in ipairs(expected) do
            local b=p.run.battle;assert(b.round==round)
            equal(b.intent,{kind=stage[1],target=stage[2],damage=stage[3]})
            local copy=util.copy(p);valid(copy)
            local before=util.copy(p);local forecast=model.combat.preview(p.run);equal(before,p)
            command(p,"battle_step");command(copy,"battle_step");equal(p,copy)
            if not forecast.outcome then assert(p.run.crew[1].stamina==before.run.crew[1].stamina-forecast.energy[1]) end
            assert(p.run.rng.combat==rng)
        end
        assert(p.run.mode=="combat_result" and p.run.battle.outcome=="fallback")
    end)
    test("guardian warning cannot spend abilities or create a free follow-up",function()
        local p=setup({"bellmoth","cindercoil"});command(p,"battle_start",{team={1,2}})
        command(p,"battle_step")
        local cargo=p.run.cargo;local condition=p.run.crew[1].condition
        local preview=model.combat.preview(p.run)
        assert(preview.abilities[1].code=="warning" and preview.abilities[2].code=="warning")
        command(p,"battle_step")
        assert(not next(p.run.battle.used))
        assert(p.run.battle.history[2].pressure==17 and p.run.battle.history[2].damage==0)
        assert(p.run.cargo==cargo and p.run.crew[1].condition==condition)
    end)
    test("guardian inspection preserves the authored pattern and exact original event",function()
        local p=setup({"brindlehorn","loamling"});local original=util.copy(p.run.pending)
        local rng=util.copy(p.run.rng)
        assert(model.combat.setup_text(p.run):find("approach warning 0",1,true))
        for _=1,3 do
            command(p,"battle_start",{team={2,1}});command(p,"battle_back")
            equal(original,p.run.pending);equal(rng,p.run.rng)
            command(p,"choice",{id="battle"})
        end
    end)
    test("guardian saves reject malformed patterns while ordinary saves keep old rules",function()
        local p=setup();command(p,"battle_start",{team={1}})
        for _,change in ipairs({function(b) b.pattern="unknown" end,function(b) b.kind="scavengers" end,
            function(b) b.intent.damage=0 end,function(b) b.intent.target=1 end}) do
            local bad=util.copy(p);change(bad.run.battle);assert(not save.validate(bad))
        end
        local old=model.new(1848);command(old,"depart")
        assert(model.debug(old,"event","territorial"));command(old,"choice",{id="battle"});command(old,"battle_start",{team={1,2}})
        assert(old.run.battle.pattern==nil)
        command(old,"battle_step");assert(old.run.battle.intent.kind=="heavy")
    end)
end
