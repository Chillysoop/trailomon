local w=require "ui.widgets"
local combat=require "simulation.wagon_combat"
local controller=require "services.ambush_controller"
local content=require "content.ambush"
local items=require "content.work_items"
local view=require "presentation.ambush"
local M={}
local function next_creature(s,id)
    local index;for i,key in ipairs(content.crew) do if key==id then index=i end end
    for n=1,#content.crew do local key=content.crew[(index+n-1)%#content.crew+1];if not combat.unit(s,key) then return key end end
end
local function next_item(self,u)
    local order=content.item_order;local index=1
    for i,key in ipairs(order) do if key==(u.item or "") then index=i end end
    for n=1,#order do local key=order[(index+n-1)%#order+1];if key=="" or not (self.ambush.practice or self.ambush.road) or (self.snapshot.run.work_items or {})[key] then return key end end
end
local results={victory="Wagon defended",wagon_lost="Wagon disabled",crew_down="Crew needs care",retreated="Withdrew safely",stalemate="Stalemate / withdrew"}
local function action(self,id,arg) return function() controller.command(self,id,arg) end end
local function name(s,id)
    if id=="wagon" then return "wagon" end
    local u=combat.unit(s,id);return u and view.short(combat.kit(s,u.id).name,22) or id
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

local function center(self,x,y,text,size,color)
    local node=w.text(self,x,y,text,size,color);gui.set_pivot(node,gui.PIVOT_CENTER);return node
end
local function selection(self,u)
    self.ambush.selected=u.id;self.ambush.show_log=false;self.redraw()
end
local function field(self)
    -- A quiet woodland clearing. Existing palette and wagon prop; no new art dependency.
    w.rect(self,20,234,1240,392,"263e33")
    for i=0,9 do
        local x=20+i*133
        w.rect(self,x,491,42+(i%3)*8,135,"1e332b")
        w.rect(self,x+48,494,72,35+(i%4)*12,"35503c")
    end
    w.rect(self,20,234,1240,263,"657256")
    w.rect(self,20,425,1240,38,"89906b")
    w.rect(self,20,288,1240,30,"89906b")
    for i=1,28 do
        local x=26+(i*137)%1200;local y=242+(i*71)%232
        w.rect(self,x,y,15+(i%4)*9,3,i%3==0 and "a3a17a" or "566648")
    end
    require("presentation.wagon_prop").draw(self,165,420,"light")
end
local function meters(self,u,x,y)
    w.rect(self,x-72,y+84,144,43,"dark")
    w.icon(self,x-66,y+108,"condition",11)
    w.bar(self,x-49,y+110,80,100*u.hp/u.max_hp,w.tint("condition"),7)
    w.text(self,x+36,y+113,u.hp,11,"ink")
    w.icon(self,x-66,y+94,"focus",11)
    w.bar(self,x-49,y+96,80,100*u.focus/u.cost,w.tint("focus"),5)
    w.text(self,x+36,y+99,u.focus,10,"ink")
    local interval=combat.interval(u)
    w.bar(self,x-49,y+87,110,100*(1-u.attack_left/interval),w.tint("time"),3)
end
local function unit(self,u)
    local a=self.ambush;local s=a.battle;local k=combat.kit(s,u.id);local x,y=view.point(u)
    local selected=a.selected==u.id
    w.rect(self,x-41,y+1,82,5,"45543e")
    if selected then w.rect(self,x-49,y-3,98,3,"gold") end
    local dx,dy=view.motion(s,u,a.carry,self.snapshot.settings.motion)
    local node=w.sprite(self,k.species,x+dx,y+43+dy,104,u.hp==0)
    self.animated[#self.animated+1]={node=node,x=x,y=y+43,ambush=u.id}
    if u.side=="foe" then gui.set_scale(node,vmath.vector3(-1,1,1)) end
    meters(self,u,x,y)
    local status={}
    if u.hp==0 then status[#status+1]="OUT" end
    if u.shield>0 then status[#status+1]="Shield "..u.shield end
    for _,id in ipairs({"stun","slow","expose","lure"}) do if s.phase=="fight" and combat.has(u,id) then status[#status+1]=({stun="STUN",slow="SLOW",expose="EXPOSED",lure="DRAWN"})[id] end end
    if #status>0 then center(self,x,y+138,table.concat(status," / "),11,"ink") end
    w.button(self,x-80,y-26,160,23,view.short(k.name,20),function() selection(self,u) end,{key="ambush_select_"..u.id,selected=selected,size=12})
    self.buttons[#self.buttons].hit_node=node
    if s.phase=="setup" then
        local label=combat.positions[u.position]
        local initial=a.road and self.snapshot.run.wagon_battle.initial.crew[u.id]
        if initial then label=label.." / Energy "..math.floor(initial.stamina)..(initial.active and "" or " / resting") end
        center(self,x,y-39,label,10,"dark")
    end
    local f=view.feedback(s,u.id)
    if s.phase=="fight" then
        if f.hit then center(self,x+66,y+56,"-"..f.hit.value,21,"ink") end
        if f.support then
            local e=f.support;local label=e.kind=="absorbed" and ("Block "..e.value) or ("+"..e.value)
            center(self,x-65,y+63,label,13,w.tint("guard"))
        end
        if f.cast then
            w.rect(self,x-90,y-49,180,20,"dark");center(self,x,y-39,k.skill,11,w.tint("focus"))
        end
    end
end
local function wagon(self)
    local s=self.ambush.battle;local v=s.wagon
    w.rect(self,56,531,218,58,"dark")
    w.reading(self,68,573,"wagon",v.hp.." / 100",{size=16,icon_size=19})
    w.bar(self,68,550,194,v.hp,w.tint("wagon"),6)
    w.text(self,68,540,"Shield "..v.shield..(v.hp<=25 and " / IN DANGER" or ""),10,v.hp<=25 and "red" or "muted")
    local f=view.feedback(s,"wagon")
    if s.phase=="fight" and f.hit then center(self,245,482,"-"..f.hit.value,23,"ink") end
    if s.phase=="fight" and f.support then center(self,88,483,"+"..f.support.value,16,w.tint("guard")) end
    if s.phase=="setup" then
        center(self,165,393,combat.target(s,combat.unit(s,"raider")).id=="wagon" and "OPEN LANE / wagon at risk" or "Front 1 protects the wagon",11,"ink")
    end
end
local function contributions(self)
    local s=self.ambush.battle
    if s.phase=="setup" then return end
    w.rect(self,28,245,238,137,"dark");w.text(self,40,365,"CREW DAMAGE",11,"muted")
    local total=0;for _,u in ipairs(combat.crew(s)) do total=total+u.stats.damage end
    for i,u in ipairs(combat.crew(s)) do
        local y=342-(i-1)*34
        w.text(self,40,y,view.short(combat.kit(s,u.id).name,18),12,"ink")
        w.text(self,209,y,u.stats.damage,12,"ink")
        w.bar(self,40,y-12,207,100*u.stats.damage/math.max(1,total),w.tint("pressure"),3)
    end
end
local function inspector(self,u)
    local a=self.ambush;local s=a.battle;local k=combat.kit(s,u.id);local setup=s.phase=="setup"
    w.rect(self,20,55,810,163,"dark")
    w.text(self,32,197,view.short(k.name,20),20,"ink")
    w.text(self,32,175,k.species.." / "..combat.positions[u.position],11,"muted")
    w.reading(self,32,150,"condition",u.hp.."/"..u.max_hp,{label="HP",size=12,icon_size=14})
    w.reading(self,160,150,"guard",combat.defense(u),{label="DEF",size=12,icon_size=14})
    w.reading(self,32,127,"focus",u.focus.."/"..u.cost,{size=12,icon_size=14})
    w.reading(self,160,127,"time",string.format("%.1fs",u.attack_left/10),{label="Hit",size=12,icon_size=14})
    local target=u.hp>0 and combat.target(s,u)
    w.text(self,32,100,target and ("Target: "..view.short(name(s,target.id),24)) or (u.hp==0 and "Needs care" or "Fight complete"),11,"muted")
    if s.phase=="result" then w.text(self,32,77,u.stats.attacks.." hits / "..u.stats.casts.." abilities",11,"ink") end
    w.text(self,300,196,k.skill.." / "..u.cost.." Focus",15,w.tint("focus"))
    w.text(self,300,177,k.active,12,"ink",300)
    w.text(self,300,139,k.passive,11,"muted",300)
    local gear=items.defs[u.item]
    if setup and u.side=="crew" then
        if not a.practice and not a.road and s.rules==combat.RULES then
            local next_id=next_creature(s,u.id)
            w.button(self,620,173,196,31,"Swap > "..view.short(combat.kits[next_id].species,16),function()
                a.selected=next_id;controller.command(self,"replace",{id=u.id,replacement=next_id})
            end,{key="ambush_swap_"..u.id,size=12})
        end
        w.button(self,620,136,196,31,"Move > "..combat.positions[u.position%4+1],action(self,"move",{id=u.id,position=u.position%4+1}),{key="ambush_move_"..u.id,size=12})
        if s.rules==combat.RULES then w.button(self,620,99,196,31,gear and gear.name or "Gear: none",action(self,"equip",{id=u.id,item=next_item(self,u)}),{key="ambush_item_"..u.id,size=12,icon=gear and gear.icon or "capacity"}) end
    else
        w.text(self,620,197,"CONTRIBUTION",11,"muted")
        w.text(self,620,173,u.stats.damage.." damage / "..u.stats.casts.." abilities",12,"ink")
        local details={}
        for _,entry in ipairs({{"intercepts","intercepts"},{"reactions","follow-ups"},{"stuns","interrupts"},{"openings","openings"},{"shielded","shield given"}}) do
            if (u.stats[entry[1]] or 0)>0 then details[#details+1]=u.stats[entry[1]].." "..entry[2] end
        end
        w.text(self,620,150,table.concat(details," / "),11,"ink",190)
        if gear then w.text(self,620,109,gear.name.." / "..(u.stats.item_procs or 0).." triggers",11,"gold",190) end
    end
    w.text(self,300,98,gear and gear.wagon or (u.side=="crew" and "No equipment" or k.passive),11,gear and "gold" or "muted",300)
end
local function log_panel(self)
    local a=self.ambush;if not a.show_log then return end
    local s=a.battle
    w.panel(self,746,242,506,374);w.text(self,762,594,"BATTLE LOG",14,"gold")
    local start=math.max(1,#s.events-9)
    for i=start,#s.events do local e=s.events[i];w.text(self,762,566-(i-start)*31,string.format("%4.1f ",e.tick/10)..event_text(s,e),11,"ink",472) end
end
function M.draw(self)
    local a=self.ambush;local s=a.battle;local setup=s.phase=="setup"
    if setup then a.show_log=false end
    local selected=combat.unit(s,a.selected or "")
    if not selected or selected.id=="wagon" then selected=combat.crew(s)[1];a.selected=selected.id end
    w.text(self,28,689,a.practice and "MARA / WAGON DRILL" or (a.road and (s.scenario=="scavengers" and "GRAIN RAID" or "RIDGE TERRITORY") or "WAGON AMBUSH"),24,"ink")
    w.text(self,28,664,a.practice and "Practice / health and cargo safe" or (a.road and "Real crew / wagon / carried supplies" or "Sample / loaned crew and gear"),12,"muted")
    center(self,690,688,setup and "FORM YOUR CREW" or (s.phase=="result" and results[s.result] or (a.paused and "PAUSED" or "DEFEND THE WAGON")),19,"gold")
    if not setup then center(self,690,662,string.format("%.1fs",s.tick/10).." / "..a.speed.."x",12,"muted") end
    w.button(self,870,666,170,32,a.road and "Reload checkpoint" or "Reload sample",action(self,"reload"),{key="ambush_reload",size=12})
    w.button(self,1052,666,200,32,a.road and (s.phase=="result" and "Continue journey" or "Back to choices") or "Back to journey",function()
        if a.road then controller.road_exit(self) else controller.pause(self);self.open_page("trail") end
    end,{key="ambush_back",size=12,enabled=not a.road or s.phase=="result" or require("simulation.wagon_road").can_back(self.snapshot.run)})
    if setup and not a.practice and not a.road then
        for i,id in ipairs({"guard","rush","control"}) do w.button(self,28+(i-1)*170,631,162,27,combat.presets[id].label,action(self,"new",id),{key="ambush_"..id,selected=s.preset==id,size=12}) end
    else w.text(self,28,641,setup and "Your traveling crew / your carried gear" or "Select a creature to inspect",12,"muted") end
    w.text(self,916,641,"HP / Focus / attack clock",11,"muted")
    field(self)
    if setup then
        for pos=1,4 do
            local found=false;for _,u in ipairs(combat.crew(s)) do if u.position==pos then found=true end end
            if not found then local x,y=view.point({side="crew",position=pos});w.rect(self,x-43,y,86,3,"adbc9f");center(self,x,y-16,combat.positions[pos].." / open",11,"dark") end
        end
    end
    wagon(self);contributions(self)
    -- Far row first, then near row. Units occupy a scene, never card containers.
    for _,near in ipairs({false,true}) do for _,u in ipairs(s.units) do local _,y=view.point(u);if (y<400)==near then unit(self,u) end end end
    inspector(self,selected)
    if setup then
        local ready=not a.road or require("simulation.wagon_road").ready(self.snapshot.run,s)
        w.button(self,850,169,402,44,(a.practice or a.road) and "Start / -6 Energy per fighter" or "Start ambush",action(self,"start"),{key="ambush_start",primary=true,size=16,enabled=ready and (not a.practice or require("simulation.wagon_practice").ready(self.snapshot.run,s))})
        w.text(self,850,145,"Attacks and abilities repeat automatically.",13,"ink")
        w.text(self,850,119,a.road and "OUT: needs 6 Energy + positive Condition" or "Select a creature / set position and gear.",12,"muted")
        w.text(self,850,91,a.practice and "Borrowed medicine and repair / no rewards" or (a.road and "Max 1 carried medicine + 1 repair / no new rewards" or "One copy per item / setup locks at Start"),11,"muted")
        if a.road then w.button(self,850,56,402,28,"Withdraw / "..(s.scenario=="scavengers" and ("up to "..require("simulation.equipment").retreat_loss(self.snapshot.run).." food + cargo") or "+1 day / meals"),action(self,"retreat"),{key="ambush_retreat",size=12}) end
    elseif s.phase=="fight" then
        w.button(self,850,177,194,36,a.paused and "Resume" or "Pause",action(self,"pause"),{key="ambush_pause",primary=true,size=14})
        w.button(self,1056,177,196,36,"Speed "..a.speed.."x",action(self,"speed"),{key="ambush_speed",size=14})
        if s.rules==combat.RULES then for i,id in ipairs({"medicine","repairs"}) do
            local target=combat.supply_target(s,id);local amount=target and math.min(target.max_hp-target.hp,id=="medicine" and 28 or 20) or 0
            local label=(id=="medicine" and "Med +"..amount.." HP" or "Fix +"..amount.." wagon").." / "..s.supplies[id]
            w.button(self,850+(i-1)*206,135,196,32,label,action(self,"supply",id),{key="ambush_supply_"..id,size=11,icon=id,enabled=a.paused and target~=nil})
        end end
        w.text(self,850,119,"Pause for supplies / SPACE pause",11,"muted")
        w.button(self,850,66,194,33,a.road and (s.scenario=="scavengers" and "Withdraw / food + cargo" or "Withdraw / +1 day") or "Withdraw",action(self,"retreat"),{key="ambush_retreat",size=11})
        if a.road then w.text(self,850,106,s.scenario=="scavengers" and ("Up to "..require("simulation.equipment").retreat_loss(self.snapshot.run).." food + cargo on defeat / withdrawal") or "Defeat / withdrawal: +1 day and meals",10,"muted") end
    else
        local receipt=a.road and self.snapshot.run.wagon_battle and self.snapshot.run.wagon_battle.receipt
        w.text(self,850,195,receipt and string.format("Wagon %+.0f / Cargo %+.0f",receipt.wagon,receipt.cargo) or ("Wagon damage: "..(100-s.wagon.hp)),18,"ink")
        w.text(self,850,168,receipt and string.format("Food %+d / Days +%d / Med %d / Fix %d",receipt.food,receipt.days,receipt.medicine,receipt.repairs) or (a.practice and "6 Energy each spent once / health safe" or "Sample / no expedition penalties"),12,"muted")
        if receipt then
            for i,u in ipairs(combat.crew(s)) do local v=receipt.crew[u.id];w.text(self,850,143-(i-1)*19,string.format("%s  Energy %+.0f / Condition %+.0f",view.short(name(s,u.id),14),v.energy,v.condition),11,"ink") end
        elseif not a.practice and not a.road then w.button(self,850,111,402,40,"New sample",action(self,"new",s.preset),{key="ambush_new",primary=true,size=14}) end
    end
    if not setup then w.button(self,1056,66,196,33,a.show_log and "Close log" or "Battle log",function() a.show_log=not a.show_log;self.redraw() end,{key="ambush_log",selected=a.show_log,size=13}) end
    log_panel(self)
    w.text(self,28,36,"Select / TAB + ENTER",11,"muted")
    w.text(self,300,36,a.error or a.notice or ((a.practice or a.road) and "Saved with journey / reload pauses" or "Separate checkpoint / reload pauses"),11,a.error and "red" or "muted")
end
return M
