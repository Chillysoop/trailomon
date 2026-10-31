-- Exercise the actual GUI controller with no rendering, sound, or disk side effects.
local model=require "simulation.expedition"
local util=require "simulation.util"
return function(test,command,valid,equal)
    test("actual controller coalesces redraws and pauses on focus, menus and reload",function()
        local p=model.new(1848);command(p,"depart")
        assert(model.debug(p,"event","scavengers"));command(p,"choice",{id="battle"})
        local stored=util.copy(p);local draws=0;local writes=0;local listener;local fail_save=false
        local modules={
            ["services.save"]={load=function() return util.copy(stored) end,write=function(snapshot) valid(snapshot);if fail_save then return false,"Test save failure" end;stored=util.copy(snapshot);writes=writes+1;return true end},
            ["ui.screens"]={draw=function() draws=draws+1 end},
            ["presentation.scene"]={update=function() end},
        }
        local env=setmetatable({
            hash=function(value) return value end,
            require=function(name) return modules[name] or require(name) end,
            msg={post=function() end},sound={play=function() end},
            window={WINDOW_EVENT_FOCUS_LOST=1,WINDOW_EVENT_FOCUS_GAINED=2,WINDOW_EVENT_ICONIFIED=3,WINDOW_EVENT_DEICONIFIED=4,set_listener=function(fn) listener=fn end},
        },{__index=_G})
        modules["ui.input"]=setfenv(assert(loadfile("ui/input.lua")),env)()
        setfenv(assert(loadfile("ui/game.gui_script")),env)()
        local ui={};env.init(ui)
        assert(type(ui.buttons)=="table" and type(ui.animated)=="table")
        env.on_input(ui,nil,{x=100,y=100})
        env.update(ui,0)
        ui.perform("battle_start",{team={1,2}});ui.redraw();ui.redraw()
        assert(draws==1,"Redraws must be deferred")
        env.update(ui,0);assert(draws==2)
        assert(not ui.combat_paused)
        for _=1,40 do env.update(ui,0.1) end
        assert(#ui.snapshot.run.battle.history==0)
        listener(nil,1);assert(ui.combat_paused and not ui.has_focus)
        for _=1,100 do env.update(ui,0.1) end
        assert(#ui.snapshot.run.battle.history==0)
        listener(nil,2);assert(ui.combat_paused and ui.has_focus)
        ui.toggle_combat();ui.open_page("journal");assert(ui.combat_paused)
        ui.open_page("trail");assert(ui.combat_paused)
        ui.toggle_combat()
        for _=1,51 do env.update(ui,0.1) end
        assert(#ui.snapshot.run.battle.history==1)
        assert(stored.run.battle.history[1].round==1 and writes>=3)
        local saved=util.copy(stored);local resumed={};env.init(resumed);env.update(resumed,0)
        assert(resumed.combat_paused);equal(saved,resumed.snapshot)
        for _=1,100 do env.update(resumed,0.1) end
        equal(saved,resumed.snapshot)
        fail_save=true;resumed.save_now();resumed.toggle_combat()
        for _=1,100 do env.update(resumed,0.1) end
        equal(saved,resumed.snapshot)
        assert(resumed.save_error,"An unsaved combat must stop its automatic clock")
        fail_save=false
        local travel=model.new(1848);command(travel,"depart");command(travel,"resume")
        stored=travel;local moving={};env.init(moving)
        assert(moving.speed==1 and moving.snapshot.run.mode=="stopped")
        moving.perform("settings",{key="travel_speed"});assert(moving.speed==2 and stored.settings.travel_speed==2)
        moving.perform("resume");local reload={};env.init(reload)
        assert(reload.speed==2 and reload.snapshot.run.mode=="stopped","Remember viewing speed but never resume travel on load")
        stored.settings.travel_speed=nil;local old={};env.init(old);assert(old.speed==1)
    end)
end
