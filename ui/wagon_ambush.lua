local w=require "ui.widgets"
local combat=require "simulation.wagon_combat"
local controller=require "services.ambush_controller"
local content=require "content.ambush"
local items=require "content.work_items"
local M={}
local function next_creature(s,id)
    local index;for i,key in ipairs(content.crew) do if key==id then index=i end end
    for n=1,#content.crew do local key=content.crew[(index+n-1)%#content.crew+1];if not combat.unit(s,key) then return key end end
end
local function next_item(self,u)
    local order=content.item_order;local index=1
    for i,key in ipairs(order) do if key==(u.item or "") then index=i end end
    for n=1,#order do local key=order[(index+n-1)%#order+1];if key=="" or not self.ambush.practice or (self.snapshot.run.work_items or {})[key] then return key end end
end
local results={victory="Wagon defended",wagon_lost="Wagon disabled",crew_down="Crew needs care",retreated="Withdrew safely",stalemate="Stalemate / withdrew"}
local function action(self,id,arg) return function() controller.command(self,id,arg) end end
local function name(s,id)
    if id=="wagon" then return "wagon" end
    local u=combat.unit(s,id);return u and combat.kit(s,u.id).name or id
end
local function event_text(s,e)
    local a,b=name(s,e.source),name(s,e.target)
    if e.kind=="cast" then return a..": "..combat.kit(s,e.source).skill end
    if e.kind=="intercept" then return a.." intercepted "..b end
    if e.kind=="shield" then return a.." shielded "..b.." +"..e.value end
    if e.kind=="stun" then return a.." interrupted "..b end
    if e.kind=="slow" then return b.." slowed / 3s" end
    if e.kind=="focus" then return b.." +"..e.value.." Focus" end
    if e.kind=="expose" then return b.." exposed / 3s" end
    if e.kind=="quick" then return a.." attack sooner / 0.5s" end
    if e.kind=="rope" then return a.." rope exploits opening +4" end
    if e.kind=="supply" then return (e.source=="medicine" and "Medicine: " or "Repair: ")..b.." +"..e.value end
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
    local a=self.ambush;local s=a.battle;local k=combat.kit(s,u.id);local setup=s.phase=="setup"
    w.panel(self,x,y,width,178)
    w.sprite(self,k.species,x+34,y+138,58,u.hp==0)
    w.text(self,x+67,y+158,k.name,16,"ink")
    w.text(self,x+67,y+137,(u.hp==0 and "OUT" or combat.positions[u.position]).." / DEF "..combat.defense(u),11,u.hp==0 and "red" or "muted")
    w.text(self,x+67,y+121,"Shield "..u.shield,10,"muted")
    meter(self,x+12,y+107,"condition","HP",u.hp,u.max_hp,width-24)
    if not setup or u.side=="foe" then meter(self,x+12,y+78,"focus","Focus",u.focus,u.cost,width-24) end
    w.text(self,x+12,y+(setup and u.side=="crew" and 86 or 48),k.skill..(setup and u.side=="crew" and (" / "..u.cost.." Focus") or ""),11,"ink")
    if setup then
        if u.side=="crew" then
            local next_id=next_creature(s,u.id)
            if not a.practice and s.rules==combat.RULES then
                w.button(self,x+12,y+56,width-24,22,"Swap > "..combat.kits[next_id].species,action(self,"replace",{id=u.id,replacement=next_id}),{key="ambush_swap_"..u.id,size=11})
            end
            w.button(self,x+12,y+31,width-24,22,"Move > "..combat.positions[u.position%4+1],action(self,"move",{id=u.id,position=u.position%4+1}),{key="ambush_move_"..u.id,size=11})
            if s.rules==combat.RULES then
                local gear=items.defs[u.item];local next_gear=next_item(self,u)
                w.button(self,x+12,y+6,width-24,22,gear and gear.name or "Gear: none",action(self,"equip",{id=u.id,item=next_gear}),{key="ambush_item_"..u.id,size=11,icon=gear and gear.icon or "capacity"})
            end
        else
            w.text(self,x+12,y+31,k.active,10,"muted")
            w.text(self,x+12,y+12,u.id=="raider" and "RAIDER > lane 1 / wagon" or "DISRUPTOR > exposed crew",11,"gold")
        end
    else
        local status=(combat.has(u,"stun") and "STUN / " or (combat.has(u,"slow") and "SLOW / " or (combat.has(u,"expose") and "EXPOSED / " or ""))).."clock "..string.format("%.1fs",u.attack_left/10)
        if u.hp==0 then status="Recover after this sample" end
        if s.phase=="result" and u.hp>0 then status=u.stats.attacks.." attacks / "..u.stats.casts.." abilities" end
        w.text(self,x+12,y+27,status,11,(combat.has(u,"stun") or combat.has(u,"slow")) and "gold" or "muted")
        w.text(self,x+12,y+10,u.hp>0 and s.phase=="fight" and ("Attack: "..name(s,u.target)) or "",10,"muted")
    end
    w.text(self,x+12,y+189,u.side=="crew" and k.species:upper() or (u.id=="raider" and "WAGON THREAT" or "CREW THREAT"),10,"muted")
end
function M.draw(self)
    local a=self.ambush;local s=a.battle;local setup=s.phase=="setup"
    w.text(self,28,683,a.practice and "MARA / WAGON DRILL" or "WAGON AMBUSH",27,"ink")
    w.text(self,28,653,a.practice and "Start: -6 Energy each / practice HP, wagon and supplies" or "BUILD SAMPLE / loaned crew, gear and supplies",12,"gold")
    w.button(self,1050,655,202,38,"Back to journey",function() controller.pause(self);self.open_page("trail") end,{key="ambush_back",size=13})
    w.button(self,850,655,185,38,"Reload sample",action(self,"reload"),{key="ambush_reload",size=13})
    w.rect(self,28,639,1224,1,"edge")
    if setup then
        if not a.practice then
            for i,id in ipairs({"guard","rush","control"}) do w.button(self,28+(i-1)*166,587,158,34,combat.presets[id].label,action(self,"new",id),{key="ambush_"..id,selected=s.preset==id,size=12}) end
        else w.text(self,28,605,"Your crew / your carried gear",17,"ink") end
        w.button(self,548,587,340,34,(a.practice and "Start drill / -6 Energy each" or "Start ambush"),action(self,"start"),{key="ambush_start",primary=true,size=15,enabled=not a.practice or require("simulation.wagon_practice").ready(self.snapshot.run,s)})
        w.text(self,916,605,"Front 1 blocks the raider.",13,"gold")
    else
        w.text(self,28,605,s.phase=="result" and results[s.result] or (a.paused and "PAUSED" or "DEFEND THE WAGON"),24,"ink")
        w.text(self,548,605,string.format("%.1fs",s.tick/10).." / "..(s.preset=="custom" and "Custom formation" or combat.presets[s.preset].label),15,"muted")
        if not a.practice then w.button(self,1002,587,250,34,"New sample",action(self,"new",s.preset),{key="ambush_new",size=13}) end
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
        w.text(self,548,545,"CREW ABILITIES & GEAR",12,"gold")
        for i,u in ipairs(combat.crew(s)) do
            local id=u.id;local k=combat.kit(s,id);local y=507-(i-1)*118
            w.text(self,548,y,k.name.." / "..k.skill,16,"ink")
            w.text(self,548,y-25,k.active,12,"muted",336)
            w.text(self,548,y-49,k.passive,12,"muted",336)
            local gear=items.defs[u.item];if gear then w.text(self,548,y-76,gear.wagon,11,"gold",336) end
        end
        w.text(self,548,157,"Focus +10/s; abilities repeat.",13,"ink")
        w.text(self,548,133,a.practice and "No lasting HP, cargo or wagon loss." or "Gear buttons cycle / one copy per item.",12,"muted",334)
    else
        w.text(self,548,545,s.phase=="result" and "WHO MADE THE DIFFERENCE" or "LAST ACTIONS",12,"gold")
        if s.phase=="result" then
            for i,u in ipairs(combat.crew(s)) do
                local id=u.id
                if u then
                    local y=506-(i-1)*76
                    w.text(self,548,y,combat.kit(s,id).name.." / "..u.stats.damage.." damage",16,"ink")
                    local reason=(id=="moss" or id=="ripple") and (u.stats.intercepts.." intercepts") or (id=="ember" and (u.stats.reactions.." follow-ups") or (id=="pip" and ((u.stats.openings or 0).." openings") or (id=="flint" and ((u.stats.shielded or 0).." shield given") or (u.stats.stuns.." interrupts"))))
                    w.text(self,548,y-23,u.stats.casts.." abilities / "..reason,12,"muted")
                    if u.item and u.item~="" then w.text(self,548,y-43,items.defs[u.item].name.." / "..u.stats.item_procs.." triggers",11,"gold") end
                end
            end
            w.text(self,548,278,"Wagon damage: "..(100-s.wagon.hp),16,"ink")
            w.text(self,548,249,a.practice and "6 Energy each spent once / health safe" or "Sample only / no expedition penalties",12,"muted")
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
    if s.phase=="fight" and s.rules==combat.RULES then
        for i,id in ipairs({"medicine","repairs"}) do
            local target=combat.supply_target(s,id)
            local amount=target and math.min(target.max_hp-target.hp,id=="medicine" and 28 or 20) or 0
            local label=(id=="medicine" and "Medicine +"..amount.." HP" or "Repair +"..amount.." wagon").." / "..s.supplies[id]
            w.button(self,916,101-(i-1)*38,336,32,label,action(self,"supply",id),{key="ambush_supply_"..id,size=12,icon=id,enabled=a.paused and target~=nil})
        end
        w.text(self,916,47,"Pause to use / borrowed practice supplies",10,"muted")
    else w.text(self,916,96,"Creature shields do not repair the wagon.",11,"muted",330) end
    w.text(self,28,22,a.error or a.notice or (a.practice and "Practice saved with this journey / reload resumes paused" or "Separate sample checkpoint / reload resumes paused"),11,a.error and "red" or "muted")
end
return M
