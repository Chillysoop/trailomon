local model=require "simulation.expedition"
local util=require "simulation.util"
local progression=require "simulation.progression"
local save=require "services.save"
local clock=require "services.travel_clock"
return function(test,command,valid,equal)
    local function encounter(ids,kind,seed)
        local p=model.new(seed or 1848);command(p,"depart")
        p.run.crew={};for _,id in ipairs(ids) do p.run.crew[#p.run.crew+1]=progression.companion(id) end
        p.run.mode="combat_select";p.run.encounter=kind or "territorial"
        local team={1};if #ids>1 then team[2]=2 end
        command(p,"battle_start",{team=team});return p
    end
    local function threat(p,target,heavy,damage)
        p.run.battle.intent={target=target or "cargo",kind=heavy and "heavy" or "rush",damage=damage or 14}
    end
    test("automatic setup rejects invalid teams without consuming RNG",function()
        local p=encounter({"brindlehorn","cindercoil"});p.run.mode="combat_select";p.run.encounter="scavengers"
        for _,team in ipairs({{}, {1,1}, {4}, {1,2,3}}) do
            local before=util.copy(p);assert(not model.command(p,"battle_start",{team=team}));equal(p,before)
        end
        command(p,"battle_start",{team={2,1}});equal(p.run.battle.team,{2,1})
        local before=util.copy(p);assert(not model.command(p,"round",{actions={}}));equal(p,before)
    end)
    test("partner cover triggers one warmth display with persistent exact costs",function()
        local p=encounter({"brindlehorn","cindercoil"});threat(p)
        command(p,"battle_step")
        local b=p.run.battle
        assert(b.used[1] and b.used[2]);assert(b.history[1].damage==0 and b.history[1].pressure==40)
        assert(p.run.crew[1].stamina==88 and p.run.crew[2].stamina==88)
        threat(p);command(p,"battle_step")
        assert(p.run.crew[1].stamina==84 and p.run.crew[2].stamina==84)
        assert(b.history[2].pressure==20,"Once-only abilities repeated")
    end)
    test("ground, rain and positions produce their displayed ability effects",function()
        local function hit(ids,terrain,weather,heavy,target)
            local p=encounter(ids);p.run.terrain=terrain or "meadow";p.run.weather=weather or "clear"
            threat(p,target,heavy,heavy and 20 or 14);command(p,"battle_step");return p.run.battle,p
        end
        local soft=hit({"loamling","cindercoil"});local rock=hit({"loamling","cindercoil"},"ridge")
        assert(soft.history[1].damage==0 and rock.history[1].damage==4)
        local dry=hit({"bellmoth","cindercoil"},"meadow","clear",true)
        local wet=hit({"bellmoth","cindercoil"},"meadow","rain",true)
        assert(dry.used[1] and wet.used[1] and dry.history[1].damage==0 and wet.history[1].damage==6)
        local normal=hit({"bellmoth","cindercoil"});assert(not normal.used[1])
        local reed=hit({"reedskipper","bellmoth"});assert(reed.used[1] and reed.history[1].pressure==20)
        local stone=hit({"bellmoth","slatewhorl"});assert(stone.used[2] and stone.history[1].damage==0)
        local exposed=hit({"slatewhorl","bellmoth"});assert(not exposed.used[1])
        local selfhit=hit({"brindlehorn","bellmoth"},nil,nil,false,1);assert(not selfhit.used[1])
    end)
    test("repelled threats deal no final hit and unused abilities cost nothing",function()
        local p=encounter({"brindlehorn","cindercoil"});p.run.battle.resolve=15;threat(p)
        command(p,"battle_step")
        assert(p.run.mode=="combat_result" and p.run.cargo==100 and p.run.battle.outcome=="won")
        assert(p.run.crew[1].stamina==96 and not next(p.run.battle.used))
    end)
    test("exhaustion cannot grant full protection or a final-exchange free victory",function()
        local p=encounter({"brindlehorn"},"scavengers");p.run.crew[1].stamina=3;threat(p)
        command(p,"battle_step")
        assert(p.run.mode=="combat_result" and p.run.battle.outcome=="fallback")
        assert(p.run.battle.history[1].pressure==0 and p.run.battle.history[1].cover==0)
        assert(p.run.crew[1].stamina==3 and not next(p.run.battle.used))
    end)
    test("withdrawal and result acknowledgement charge once and survive checkpoints",function()
        for _,kind in ipairs({"scavengers","territorial"}) do
            local p=encounter({"brindlehorn","loamling"},kind)
            local food,day,cargo=p.run.food,p.run.day,p.run.cargo
            command(p,"withdraw");valid(p)
            local result=util.copy(p);assert(not model.command(p,"withdraw"));equal(p,result)
            assert(not model.command(p,"battle_step"));equal(p,result)
            if kind=="scavengers" then assert(p.run.food==food-8 and p.run.cargo==cargo-8)
            else assert(p.run.day==day+1 and p.run.food==food-model.resources.daily_food(p.run)) end
            command(p,"battle_continue");assert(p.run.mode=="stopped")
            local before=util.copy(p);assert(not model.command(p,"battle_continue"));equal(p,before)
        end
    end)
    test("inactive reserve provides no bonus, cost or battle memory",function()
        local a=encounter({"brindlehorn","cindercoil"});local b=util.copy(a)
        b.run.crew[3]=progression.companion("slatewhorl");local reserve=util.copy(b.run.crew[3])
        while a.run.mode=="combat" do command(a,"battle_step");command(b,"battle_step") end
        equal(a.run.battle,b.run.battle);equal(reserve,b.run.crew[3])
    end)
    test("automatic pause, speed, focus gaps and each saved boundary are equivalent",function()
        local function driven(seconds,pauses)
            local p=encounter({"reedskipper","cindercoil"});local c=clock.new();local frame=0
            while p.run.mode=="combat" do
                frame=frame+1;assert(frame<1000)
                if pauses and frame%73==0 then
                    for _=1,20 do assert(not clock.tick(c,0.1,false,seconds)) end
                    p=util.copy(p);valid(p)
                end
                if clock.tick(c,0.1,true,seconds) then command(p,"battle_step");p=util.copy(p);valid(p) end
            end
            return p
        end
        -- Pause only between exchanges; repeated pauses must not need wall-clock catch-up.
        equal(driven(1.5,false),driven(5,false))
        equal(driven(1.5,false),driven(5,true))
        local p=encounter({"reedskipper","cindercoil"});local copy=util.copy(p)
        while p.run.mode=="combat" do
            command(p,"battle_step");local c=clock.new();assert(not clock.tick(c,999,false,5))
            command(copy,"battle_step");copy=util.copy(copy);valid(copy)
        end
        equal(p,copy)
    end)
    test("malformed automatic saves are rejected while old manual battles stay playable",function()
        local p=encounter({"brindlehorn","loamling"})
        local fields={function(b) b.rules="future" end,function(b) b.initial=nil end,function(b) b.used[3]=true end,function(b) b.intent.target=2 end,function(b) b.history[1]={} end}
        for _,mutate in ipairs(fields) do local copy=util.copy(p);mutate(copy.run.battle);assert(not save.validate(copy)) end
        local legacy=util.copy(p);assert(require("simulation.combat_manual").start(legacy.run,"scavengers",{1,2}));valid(legacy)
        while legacy.run.mode=="combat" do command(legacy,"round",{actions={{member=1,kind="pressure"},{member=2,kind="pressure"}}}) end
        assert(legacy.run.mode=="stopped")
    end)
    test("every species and ordered pairing reaches a bounded valid outcome",function()
        local count,wins=0,{scavengers={},territorial={}}
        for _,kind in ipairs({"scavengers","territorial"}) do
            for _,a in ipairs(model.species.order) do
                for _,b in ipairs(model.species.order) do
                    for seed=1,5 do
                        local ids=a==b and {a} or {a,b};local p=encounter(ids,kind,seed)
                        local steps=0
                        while p.run.mode=="combat" do command(p,"battle_step");steps=steps+1;assert(steps<=4) end
                        assert(p.run.mode=="combat_result");valid(p);count=count+1
                        if p.run.battle.outcome=="won" then wins[kind][a.."/"..b]=true end
                    end
                end
            end
            local viable=0;for _ in pairs(wins[kind]) do viable=viable+1 end
            assert(viable>=2,"Fewer than two viable pairings for "..kind)
            print("  "..kind..": "..viable.." pairings can succeed")
        end
        print("  "..count.." bounded combat scenarios")
    end)
end
