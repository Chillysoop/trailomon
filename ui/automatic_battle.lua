local w=require "ui.widgets"
local model=require "simulation.expedition"
local util=require "simulation.util"
local scene=require "presentation.scene"
local M={}
local function text(self,x,y,t,size,color,width) return w.text(self,x,y,t,size or 12,color or "muted",width) end
local function stats(self,x,y,c)
    w.icon(self,x,y-9,"stamina",18,"sage");text(self,x+25,y,"Energy "..util.round(c.stamina),13,"ink")
    w.icon(self,x,y-34,"condition",18,"gold");text(self,x+25,y-25,"Condition "..util.round(c.condition),13,"ink")
end
function M.select(self)
    local s=self.snapshot.run;local team=self.battle_team or {};self.battle_team=team
    text(self,28,611,"ENCOUNTER / PREPARE YOUR POSITIONS")
    text(self,28,576,s.encounter=="scavengers" and "Keep the provisions safe." or "Make a little room to pass.",27,"ink")
    text(self,28,541,"Approach presses; wagon covers cargo and its partner. Rushes target cargo or the approach; every second rush is heavy. Selection order sets positions.",12,"muted",834)
    for i,c in ipairs(s.crew) do
        local idx=i;local x=28+(i-1)*280;local position
        for n,j in ipairs(team) do if i==j then position=n end end
        w.panel(self,x,240,263,270)
        text(self,x+16,484,c.name,20,"ink");text(self,x+16,460,model.species.defs[c.species].name)
        w.sprite(self,c.species,x+60,408,90);stats(self,x+115,423,c)
        local p,g=model.combat.ordinary(s,i,position or 1)
        text(self,x+16,355,position==2 and (p.." pressure + "..g.." cover / 4 energy") or (p.." pressure / 4 energy"),12,"gold")
        text(self,x+16,332,model.combat.ability_text(s,c.species),12,"ink",229)
        w.button(self,x+16,254,231,32,position and (position==1 and "1 / Approach" or "2 / Wagon") or "Choose",function()
            if position then table.remove(team,position) elseif #team<2 then team[#team+1]=idx end
            self.redraw()
        end,{key="battler"..i,selected=position~=nil,enabled=position~=nil or (#team<2 and model.resources.ready(c,4)),size=13,icon=position==2 and "wagon" or "pressure"})
    end
    text(self,28,220,"Energy: 4 per exchange +8 for one ability (up to "..(s.encounter=="scavengers" and 20 or 24).." each). Under 4: no pressure, at most 1 cover.",12)
    text(self,28,195,"Ground: "..s.terrain.." / Weather: "..s.weather.." / Reserve companions do not fight.",12)
    w.button(self,638,185,224,30,"Swap positions",function() team[1],team[2]=team[2],team[1];self.redraw() end,{key="swap_positions",enabled=#team==2,size=12})
    w.button(self,28,129,409,43,#team>0 and "Begin automatic encounter" or "Choose a companion first",function() self.perform("battle_start",{team=team}) end,{key="battle_begin",primary=true,enabled=#team>0,size=15,icon="crew"})
    w.button(self,453,129,409,43,"Withdraw",function() self.perform("withdraw") end,{key="battle_withdraw",size=14})
    text(self,28,110,model.combat.withdraw_text(s.encounter),12)
    text(self,28,79,s.encounter=="scavengers" and "Hold for 3 exchanges or reduce resolve to zero. An exhausted crew must retreat." or "Reduce resolve to zero within 4 exchanges, or take the detour.",12,"gold",834)
end
local function log_view(self,b,y)
    local n=self.combat_log or #b.history
    n=math.max(1,math.min(n,#b.history));self.combat_log=n
    local entry=b.history[n]
    if entry then
        text(self,28,y,"EXCHANGE "..entry.round.." / "..entry.summary,12,"gold")
        text(self,28,y-22,table.concat(entry.notes," "),12,"ink",834)
    else text(self,28,y,"The next rush is shown above. Pause, step, or withdraw before it resolves.",12) end
    return n
end
function M.draw(self)
    local s=self.snapshot.run;local b=s.battle
    text(self,28,611,"EXCHANGE "..b.round.." / "..b.limit.."  /  "..(self.combat_paused and "PAUSED" or "AUTOMATIC"))
    text(self,28,579,b.kind=="scavengers" and "Hold the wagon." or "Win room to pass.",26,"ink")
    text(self,28,548,model.combat.intent_text(s),14,"gold")
    w.bar(self,28,527,834,b.resolve/(b.kind=="scavengers" and 65 or 75)*100,"red",6)
    text(self,28,514,"THREAT RESOLVE "..b.resolve.." / zero ends the threat before its hit",11)
    scene.draw(self,28,324,834,175,s)
    for position,i in ipairs(b.team) do
        local c=s.crew[i];local x=28+(position-1)*425
        w.icon(self,x,294,position==1 and "pressure" or "wagon",20,"sage")
        text(self,x+28,305,(position==1 and "APPROACH / " or "WAGON / ")..c.name,15,"ink")
        local ability=b.used[i] and "ability spent" or (model.resources.ready(c,12) and "ability ready" or "ability needs rest")
        text(self,x,279,"Energy "..util.round(c.stamina).." / Condition "..util.round(c.condition).." / "..ability,12)
        text(self,x,260,model.combat.ability_text(s,c.species),12,"muted",409)
    end
    w.button(self,28,190,194,39,self.combat_paused and "Resume" or "Pause",function() self.toggle_combat() end,{key="combat_pause",primary=true,size=14,icon="time"})
    w.button(self,235,190,194,39,"Step exchange",function() self.combat_paused=true;self.perform("battle_step") end,{key="combat_step",size=14})
    w.button(self,442,190,194,39,self.combat_speed==2 and "Speed: brisk" or "Speed: calm",function() self.combat_speed=self.combat_speed==2 and 1 or 2;self.reset_clock();self.redraw() end,{key="combat_speed",size=13})
    w.button(self,649,190,213,39,"Withdraw",function() self.perform("withdraw") end,{key="battle_withdraw",size=14})
    text(self,28,174,model.combat.withdraw_text(b.kind).." Costs apply once, before the next exchange.",11)
    log_view(self,b,144)
    w.button(self,28,58,180,27,"Previous exchange",function() self.combat_paused=true;self.combat_log=math.max(1,(self.combat_log or #b.history)-1);self.reset_clock();self.redraw() end,{key="combat_previous",enabled=#b.history>1,size=11})
    w.button(self,221,58,180,27,"Latest exchange",function() self.combat_log=#b.history;self.redraw() end,{key="combat_latest",enabled=#b.history>0,size=11})
    text(self,425,72,"Menus and focus loss pause. Resume when ready.",11)
end
local function signed(n) return (n>0 and "+" or "")..util.round(n) end
function M.result(self)
    local s=self.snapshot.run;local b=s.battle;local r=b.result
    text(self,28,611,"ENCOUNTER / WHAT IT COST")
    text(self,28,575,b.outcome=="won" and "There is room for the wagon." or "Bring the crew away.",27,"ink")
    text(self,28,538,b.outcome=="won" and "The threat has passed. Effort and injuries carry into the journey." or model.combat.withdraw_text(b.kind),14)
    scene.draw(self,28,340,834,175,s)
    local costs={{"food","Provisions "..signed(r.food)},{"cargo","Cargo "..signed(r.cargo)},{"time","Days +"..r.days}}
    for n,cost in ipairs(costs) do local x=28+(n-1)*280;w.icon(self,x,303,cost[1],23,"gold");text(self,x+33,315,cost[2],17,"ink") end
    for position,i in ipairs(b.team) do
        local c=s.crew[i];local delta=r.crew[i];local x=28+(position-1)*425
        text(self,x,270,c.name,20,"ink")
        w.icon(self,x,232,"stamina",20,"sage");text(self,x+28,244,"Energy "..signed(delta.stamina).." / now "..util.round(c.stamina),14)
        w.icon(self,x,204,"condition",20,"gold");text(self,x+28,216,"Condition "..signed(delta.condition).." / now "..util.round(c.condition),14)
    end
    log_view(self,b,181)
    w.button(self,28,64,409,43,"Return to the journey",function() self.perform("battle_continue") end,{key="combat_continue",primary=true,size=15,icon="trail"})
    w.button(self,453,64,194,43,"Previous exchange",function() self.combat_log=math.max(1,(self.combat_log or #b.history)-1);self.redraw() end,{enabled=#b.history>1,size=12})
    w.button(self,660,64,202,43,"Latest exchange",function() self.combat_log=#b.history;self.redraw() end,{enabled=#b.history>0,size=12})
end
return M
