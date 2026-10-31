local model=require "simulation.expedition"
local util=require "simulation.util"
local progression=require "simulation.progression"
local clarity=require "simulation.clarity"
local symbols=require "ui.iconography"
local pixels=require "ui.icons"
return function(test,command,valid,equal)
    test("symbol catalog is complete, distinct and drawn on whole pixels",function()
        local seen,shapes={},{}
        for _,group in ipairs(symbols.groups) do
            for _,id in ipairs(group.ids) do
                assert(not seen[id],"Duplicate symbol category: "..id);seen[id]=true
                local def=symbols.get(id);assert(def.label and def.meaning and def.shape)
                local glyph=assert(pixels.glyphs[id]);assert(not shapes[glyph],"Ambiguous duplicate glyph: "..id);shapes[glyph]=true
                local rows=0
                for row in glyph:gmatch("[^/]+") do rows=rows+1;assert(#row==12 and not row:find("[^.X+]"),"Invalid pixel row: "..id) end
                assert(rows==12,"Invalid grid height: "..id)
                for _,size in ipairs({12,13,18,20,24,36}) do
                    pixels.draw({},function(_,x,y,w,h)
                        assert(x==math.floor(x) and y==math.floor(y) and w==math.floor(w) and h==math.floor(h))
                    end,0,0,id,size)
                end
            end
        end
        for id in pairs(pixels.glyphs) do assert(seen[id],"Undocumented symbol: "..id) end
        for _,id in ipairs(model.species.order) do assert(seen[symbols.role(id)]) end
    end)
    test("contextual ability forecasts match actual costs without mutating state or RNG",function()
        for _,a in ipairs(model.species.order) do
            for _,b in ipairs(model.species.order) do if a~=b then
                for _,energy in ipairs({3,8,9,16,100}) do
                    local p=model.new(37);command(p,"depart")
                    p.run.crew={progression.companion(a),progression.companion(b)}
                    for _,c in ipairs(p.run.crew) do c.stamina=energy end
                    p.run.mode="combat_select";p.run.encounter="territorial";command(p,"battle_start",{team={1,2}})
                    for _=1,4 do
                        if p.run.mode~="combat" then break end
                        local before=util.copy(p);local preview=model.combat.preview(p.run);equal(before,p)
                        -- Compare exchange effort before a forced detour applies
                        -- its separate day of meals, weather and recovery.
                        local exchange=util.copy(p.run);assert(model.combat.step(exchange))
                        command(p,"battle_step")
                        for i=1,2 do
                            assert(preview.energy[i]==before.run.crew[i].stamina-exchange.crew[i].stamina)
                            local fired=p.run.battle.used[i] and not before.run.battle.used[i]
                            assert((preview.abilities[i].code=="trigger")==not not fired)
                        end
                    end
                end
            end end
        end
    end)
    test("ability explanations distinguish wrong role, heavy rush, partner cover and fatigue",function()
        local p=model.new(11);p.run.combat_effort=nil;command(p,"depart")
        p.run.crew={progression.companion("slatewhorl"),progression.companion("bellmoth")}
        p.run.mode="combat_select";p.run.encounter="territorial";command(p,"battle_start",{team={1,2}})
        p.run.battle.intent={kind="rush",target="cargo",damage=14}
        local v=model.combat.preview(p.run)
        assert(v.abilities[1].code=="position" and v.abilities[2].code=="heavy")
        p.run.crew[1].stamina=11;assert(model.combat.preview(p.run).abilities[1].code=="energy")
        p.run.battle.used[1]=true;assert(model.combat.preview(p.run).abilities[1].code=="spent")
        p.run.crew[2]=progression.companion("cindercoil");p.run.crew[1].condition=0
        assert(model.combat.preview(p.run).abilities[2].code=="partner")
        p.run.crew[1].condition=100;p.run.crew[1].stamina=100
        p.run.battle.team={2,1};p.run.battle.used={}
        v=model.combat.preview(p.run)
        assert(v.abilities[1].code=="trigger" and v.abilities[2].code=="trigger")
        assert(v.energy[1]==12 and v.energy[2]==12)
        p.run.battle.resolve=1;assert(model.combat.preview(p.run).abilities[2].code=="repelled")
        assert(model.combat.preview(p.run).energy[2]==4)
    end)
    test("post-encounter work advice uses actual hauling, digging and crossing thresholds",function()
        local p=model.new(9);local s=p.run;s.flags.river_crossed=true
        s.crew[1].stamina=6;assert(clarity.next_duty(s).icon=="stamina" and not model.resources.hauler(s))
        s.crew[1].stamina=7;assert(model.resources.hauler(s) and clarity.next_duty(s).icon=="haul")
        s.crew[2].stamina=17;assert(clarity.next_duty(s).icon=="dig")
        s.crew[2].stamina=18;assert(clarity.next_duty(s).icon=="haul")
        s.flags.river_crossed=nil;s.crew[1].stamina=21;assert(clarity.next_duty(s).icon=="water")
        s.crew[1].stamina=22;assert(clarity.next_duty(s).icon=="haul")
        s.crew[1].condition=0;assert(clarity.next_duty(s).icon=="condition")
    end)
    test("gathering preview never promises a harvest after road closure",function()
        local p=model.new(9);command(p,"depart");p.run.day=31
        local before=p.run.food;local preview=model.forage_preview(p.run)
        assert(preview.closing and preview.packed==0 and preview.net==-preview.meals)
        command(p,"forage")
        assert(p.run.mode=="result" and p.run.day==32 and p.run.food==before+preview.net)
    end)
end
