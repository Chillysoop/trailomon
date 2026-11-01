local w=require "ui.widgets"
local combat=require "simulation.wagon_combat"
local controller=require "services.ambush_controller"
local M={}
local results={victory="Wagon defended",wagon_lost="Wagon disabled",crew_down="Crew needs care",retreated="Withdrew safely",stalemate="Stalemate / withdrew"}
local function action(self,id,arg) return function() controller.command(self,id,arg) end end
local function name(s,id)
    if id=="wagon" then return "wagon" end
    local u=combat.unit(s,id);return u and combat.kits[u.id].name or id
end
local function event_text(s,e)
    local a,b=name(s,e.source),name(s,e.target)
    if e.kind=="cast" then return a..": "..combat.kits[e.source].skill end
    if e.kind=="intercept" then return a.." intercepted "..b end
    if e.kind=="shield" then return a.." shielded "..b.." +"..e.value end
    if e.kind=="stun" then return a.." interrupted "..b end
    if e.kind=="slow" then return b.." slowed / 3s" end
    if e.kind=="focus" then return b.." +"..e.value.." Focus" end
    if e.kind=="down" then return b.." out of the fight" end
    if e.kind=="absorbed" then return a.." shield absorbed "..e.value end
    if e.kind=="result" then return results[e.target] end
    return a..(e.kind=="follow" and " follow-up: " or " > ")..b.." -"..e.value
end
local function meter(self,x,y,id,label,value,max,width)
    w.icon(self,x,y-7,id,12);w.text(self,x+19,y,label.." "..value.."/"..max,11,"ink")
    w.bar(self,x,y-13,width,100*value/max,w.tint(id),4)
end
local function card(self,u,x,y,width)
    local a=self.ambush;local s=a.battle;local k=combat.kits[u.id];local setup=s.phase=="setup"
    w.panel(self,x,y,width,178)
    w.sprite(self,k.species,x+34,y+138,58,u.hp==0)
    w.text(self,x+67,y+158,k.name,16,"ink")
    w.text(self,x+67,y+137,(u.hp==0 and "OUT" or combat.positions[u.position]).." / DEF "..(u.def+(u.id=="moss" and u.position<=2 and 55 or 0)),11,u.hp==0 and "red" or "muted")
    w.text(self,x+67,y+121,"Shield "..u.shield,10,"muted")
    meter(self,x+12,y+107,"condition","HP",u.hp,u.max_hp,width-24)
    meter(self,x+12,y+78,"focus","Focus",u.focus,u.cost,width-24)
    w.text(self,x+12,y+48,k.skill,12,"ink")
    if setup then
        if u.side=="crew" then
            w.button(self,x+12,y+9,width-24,24,"Move to "..combat.positions[u.position%4+1],action(self,"move",{id=u.id,position=u.position%4+1}),{key="ambush_move_"..u.id,size=11})
        else
            w.text(self,x+12,y+31,k.active,10,"muted")
            w.text(self,x+12,y+12,u.id=="raider" and "RAIDER > lane 1 / wagon" or "DISRUPTOR > exposed crew",11,"gold")
        end
    else
        local status=(combat.has(u,"stun") and "STUN / " or (combat.has(u,"slow") and "SLOW / " or "")).."clock "..string.format("%.1fs",u.attack_left/10)
        if u.hp==0 then status="Recover after this sample" end
        if s.phase=="result" and u.hp>0 then status=u.stats.attacks.." attacks / "..u.stats.casts.." abilities" end
        w.text(self,x+12,y+27,status,11,(combat.has(u,"stun") or combat.has(u,"slow")) and "gold" or "muted")
        w.text(self,x+12,y+10,u.hp>0 and s.phase=="fight" and ("Attack: "..name(s,u.target)) or "",10,"muted")
    end
    w.text(self,x+12,y+189,u.side=="crew" and k.species:upper() or (u.id=="raider" and "WAGON THREAT" or "CREW THREAT"),10,"muted")
end
function M.draw(self)
    local a=self.ambush;local s=a.battle;local setup=s.phase=="setup"
    w.text(self,28,683,"WAGON AMBUSH",27,"ink")
    w.text(self,28,653,"ISOLATED PROTOTYPE / Your expedition is unchanged",12,"gold")
    w.button(self,1050,655,202,38,"Back to journey",function() controller.pause(self);self.open_page("trail") end,{key="ambush_back",size=13})
    w.button(self,850,655,185,38,"Reload sample",action(self,"reload"),{key="ambush_reload",size=13})
    w.rect(self,28,639,1224,1,"edge")
    if setup then
        for i,id in ipairs({"guard","rush"}) do w.button(self,28+(i-1)*250,587,238,34,combat.presets[id].label,action(self,"new",id),{key="ambush_"..id,selected=s.preset==id,size=13}) end
        w.button(self,548,587,340,34,"Start ambush",action(self,"start"),{key="ambush_start",primary=true,size=16})
        w.text(self,916,605,"Front 1 blocks the raider.",13,"gold")
    else
        w.text(self,28,605,s.phase=="result" and results[s.result] or (a.paused and "PAUSED" or "DEFEND THE WAGON"),24,"ink")
        w.text(self,548,605,string.format("%.1fs",s.tick/10).." / "..(s.preset=="custom" and "Custom formation" or combat.presets[s.preset].label),15,"muted")
        w.button(self,1002,587,250,34,"New sample",action(self,"new",s.preset),{key="ambush_new",size=13})
    end
    w.text(self,28,562,"REAR / sheltered",12,"muted");w.text(self,278,562,"FRONT / exposed",12,"gold")
    for pos=1,4 do
        local x=pos<=2 and 278 or 28;local y=(pos-1)%2==0 and 360 or 140
        local member
        for _,u in ipairs(s.units) do if u.side=="crew" and u.position==pos then member=u end end
        if member then card(self,member,x,y,238)
        else
            w.rect(self,x,y,238,178,"dark");w.text(self,x+12,y+92,combat.positions[pos].." / open",15,"muted")
            if pos==1 then w.text(self,x+12,y+65,"Raider can reach wagon",12,"red") end
        end
    end
    for _,u in ipairs(s.units) do if u.side=="foe" then card(self,u,916,u.id=="raider" and 360 or 140,336) end end
    if setup then
        w.text(self,548,545,"THREE DIFFERENT TRICKS",12,"gold")
        for i,id in ipairs({"moss","ember","lumen"}) do
            local k=combat.kits[id];local y=507-(i-1)*96
            w.text(self,548,y,k.name.." / "..k.skill,16,"ink")
            w.text(self,548,y-25,k.active,12,"muted",336)
            w.text(self,548,y-49,k.passive,12,"muted",336)
        end
        w.text(self,548,202,"Focus +10/s; abilities repeat.",13,"ink")
        w.text(self,548,178,"Front Ember attacks faster; lane 1 opens.",12,"muted",334)
        w.text(self,548,148,"No travel Energy, food or cargo costs.",12,"muted",334)
    else
        w.text(self,548,545,s.phase=="result" and "WHO MADE THE DIFFERENCE" or "LAST ACTIONS",12,"gold")
        if s.phase=="result" then
            for i,id in ipairs({"moss","ember","lumen"}) do
                local u=combat.unit(s,id)
                if u then
                    local y=506-(i-1)*66
                    w.text(self,548,y,combat.kits[id].name.." / "..u.stats.damage.." damage",16,"ink")
                    local reason=id=="moss" and (u.stats.intercepts.." intercepts") or (id=="ember" and (u.stats.reactions.." follow-ups") or (u.stats.stuns.." interrupts"))
                    w.text(self,548,y-23,u.stats.casts.." abilities / "..reason,12,"muted")
                end
            end
            w.text(self,548,278,"Wagon damage: "..(100-s.wagon.hp),16,"ink")
            w.text(self,548,249,"Sample only / no expedition penalties",12,"muted")
        else
            local start=math.max(1,#s.events-9)
            for i=start,#s.events do
                local e=s.events[i];w.text(self,548,513-(i-start)*31,string.format("%4.1f ",e.tick/10)..event_text(s,e),11,"ink",340)
            end
            w.button(self,548,162,166,34,a.paused and "Resume" or "Pause",action(self,"pause"),{key="ambush_pause",primary=true,size=13})
            w.button(self,724,162,164,34,"Speed "..a.speed.."x",action(self,"speed"),{key="ambush_speed",size=13})
        end
    end
    w.icon(self,28,61,"wagon",36);w.text(self,76,94,"WAGON "..s.wagon.hp.." / 100",20,s.wagon.hp<=25 and "red" or "ink")
    w.bar(self,76,71,440,s.wagon.hp,w.tint("wagon"),8)
    w.icon(self,76,42,"guard",12);w.text(self,96,49,"Shield "..s.wagon.shield..(s.wagon.hp<=25 and " / IN DANGER" or ""),12,s.wagon.hp<=25 and "red" or "muted")
    if s.phase=="fight" then w.button(self,548,96,340,34,"Withdraw",action(self,"retreat"),{key="ambush_retreat",size=13}) end
    w.text(self,548,68,"SPACE pause / TAB + ENTER",11,"muted")
    w.text(self,916,96,"No creature repairs the wagon.",12,"muted")
    w.text(self,916,71,"Moss can shield it; integrity stays lost.",12,"muted")
    w.text(self,28,22,a.error or a.notice or "Separate sample checkpoint / reload resumes paused",11,a.error and "red" or "muted")
end
return M
