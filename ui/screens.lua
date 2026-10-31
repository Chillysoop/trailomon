local w=require "ui.widgets"
local scene=require "presentation.scene"
local model=require "simulation.expedition"
local util=require "simulation.util"
local wagons=require "content.wagons"
local auto_battle=require "ui.automatic_battle"
local legacy_battle=require "ui.legacy_battle"
local iconography=require "ui.iconography"
local symbol_guide=require "ui.symbol_guide"
local gathering=require "ui.gathering"
local M={}
local titles={delivered="New roots, at last.",late="You made it through.",returned="There is always another road.",rescued="Everyone comes home."}
local function cmd(self,id,args,page) return function() self.perform(id,args,page) end end
local function page(self,id) return function() self.open_page(id) end end
local function label(self,x,y,text) w.text(self,x,y,text,12,"muted") end
local function header(self)
    w.text(self,28,681,"TRAILOMON",27,"ink")
    w.text(self,28,654,"THE FERNWAKE ROAD",11,"gold")
    local pages={{"trail","Journey"},{"crew","Crew"},{"map","Map"},{"journal","Journal"},{"settings","Options"}}
    for i,item in ipairs(pages) do
        w.button(self,657+(i-1)*118,655,108,38,item[2],page(self,item[1]),{selected=self.page==item[1],size=12,icon=item[1]})
    end
    w.rect(self,28,639,1224,1,"edge")
    local s=self.snapshot.run
    local status=self.save_error or self.toast or (self.save_blocked and "Saved data needs recovery" or "Journey saved locally")
    w.text(self,28,22,status,11,self.save_error and "red" or "muted")
    w.text(self,940,22,"SPACE pause  /  TAB + ENTER",11,"muted")
end
local function sidebar(self)
    local s=self.snapshot.run
    w.panel(self,890,58,362,562)
    w.icon(self,910,584,"time",22,"gold")
    label(self,942,595,"DAY "..string.format("%02d",s.day).."  /  "..s.weather:upper())
    local stats={{"PROVISIONS",s.food,"food"},{"COINS",s.coins,"coins"},{"WAGON",util.round(s.wagon).."%","wagon"},{"CARGO",util.round(s.cargo).."%","cargo"},{"TRAVELER",util.round(s.traveler).."%","condition"},{"FOOD DAYS",model.forecast(s).days,"time"}}
    for i,stat in ipairs(stats) do
        local x=910+((i-1)%3)*111; local y=562-math.floor((i-1)/3)*68
        label(self,x,y,stat[1]);w.icon(self,x,y-40,stat[3],23,"sage");w.text(self,x+30,y-27,tostring(stat[2]),23,"ink")
    end
    w.rect(self,910,432,322,1,"edge")
    label(self,910,411,"YOUR TRAVELING COMPANY")
    for i,c in ipairs(s.crew) do
        local y=311-(i-1)*83
        w.sprite(self,c.species,944,y+34,76,c.condition<=0)
        w.text(self,987,y+59,c.name,16,"ink")
        w.text(self,987,y+39,(i==s.hauler and "HAULING" or c.duty:upper()).." / "..util.round(c.stamina).." energy",11,"muted")
        w.icon(self,987,y+18,"stamina",13,"sage");w.bar(self,1006,y+22,205,c.stamina,"sage",5)
        w.icon(self,987,y+5,"condition",13,"gold");w.bar(self,1006,y+11,205,c.condition,"gold",3)
    end
    w.icon(self,910,101,"capacity",16);label(self,932,111,model.resources.weight(s).."/"..model.resources.capacity(s))
    w.icon(self,1010,101,"repairs",16);label(self,1032,111,"Repair "..s.repairs)
    w.icon(self,1121,101,"medicine",16);label(self,1143,111,"Med "..s.medicine)
    w.button(self,910,68,322,28,"Crew, duties & care",page(self,"crew"),{size=12})
end
local function recent_log(self,x,y,width,count)
    local s=self.snapshot.run
    label(self,x,y,"NOTES FROM THE ROAD")
    for row=1,count do
        local entry=s.log[#s.log-count+row]
        if entry then
            local text="D"..entry.day.."  "..entry.text
            local limit=math.floor(width/6.7)
            if #text>limit then text=text:sub(1,limit-3).."..." end
            w.text(self,x,y-21-(row-1)*23,text,11,"muted")
        end
    end
end
local function preparation(self)
    local s=self.snapshot.run;local p=self.snapshot.profile
    label(self,28,611,"FERNWAKE DEPOT  /  DEPARTURE "..s.seed)
    w.text(self,28,572,"A small crew. A long road.",30,"ink")
    w.text(self,28,537,"Choose up to two companions. One must haul the wagon.",15,"muted")
    local selected,budget={},0
    for _,c in ipairs(s.crew) do selected[c.species]=true;budget=budget+model.species.defs[c.species].cost end
    label(self,28,508,"CREW "..#s.crew.." / 2    STARTING BUDGET "..budget.." / 7")
    for i,id in ipairs(model.species.order) do
        local def=model.species.defs[id]
        local x=28+((i-1)%3)*280; local y=292-math.floor((i-1)/3)*210
        w.panel(self,x,y,263,195)
        if selected[id] then w.rect(self,x,y+191,263,4,"sage") end
        w.sprite(self,id,x+61,y+127,108,not p.roster[id])
        w.text(self,x+124,y+157,"COST "..def.cost,12,"gold")
        w.icon(self,x+124,y+106,iconography.role(id),24,"sage")
        w.text(self,x+161,y+120,def.draft and "DRAFT" or "SUPPORT",10,"muted")
        w.text(self,x+15,y+83,def.name,19,"ink")
        label(self,x+15,y+59,def.role)
        w.button(self,x+15,y+14,233,29,p.roster[id] and (selected[id] and "Traveling with you" or "Choose companion") or "Meet on the trail",cmd(self,"crew",{species=id}),{enabled=p.roster[id]~=nil,selected=selected[id],size=12,key="select_"..id})
    end
    w.panel(self,890,58,362,562)
    label(self,910,593,"THE FIRST DELIVERY")
    w.text(self,910,560,"Orchard cuttings",23,"ink")
    w.text(self,910,529,"Carry living trees to Lantern Reach. Arrive by day 26; the road closes on day 32.",14,"muted",320)
    w.rect(self,910,449,322,1,"edge")
    label(self,910,429,"PACK YOUR WAGON")
    label(self,910,405,"COINS "..s.coins.."   LOAD "..model.resources.weight(s).." / "..model.resources.capacity(s))
    local items={{"food","Provisions",10},{"repairs","Repairs",1},{"medicine","Medicine",1}}
    for i,item in ipairs(items) do
        local y=349-(i-1)*48
        w.icon(self,910,y+5,item[1],22,"sage")
        w.text(self,942,y+17,item[2].." "..s[item[1]],14,"ink")
        w.button(self,1111,y,48,33,"-",cmd(self,"sell",{item=item[1]}),{key="sell_"..item[1]})
        w.button(self,1167,y,65,33,"+"..item[3],cmd(self,"buy",{item=item[1]}),{key="buy_"..item[1]})
    end
    label(self,910,218,"Meals: "..model.resources.daily_food(s).." / day, about "..model.forecast(s).days.." days packed")
    w.button(self,910,163,154,32,"Open wagon",cmd(self,"wagon",{id="standard"}),{selected=s.wagon_type=="standard",size=12})
    w.button(self,1074,163,158,32,"Covered",cmd(self,"wagon",{id="covered"}),{selected=s.wagon_type=="covered",enabled=p.covered,size=12})
    label(self,910,144,p.covered and "Canvas trades capacity for rain protection." or "Study Willowford to unlock a covered wagon.")
    w.button(self,910,80,322,45,"BEGIN THE JOURNEY",cmd(self,"depart",nil,"trail"),{primary=true,size=16,icon="trail"})
end
local function travel(self)
    local s=self.snapshot.run
    label(self,28,611,"THE ROAD TO "..model.route[s.target].name:upper())
    w.text(self,28,578,s.mode=="traveling" and "Let the road unfold." or "A moment to take stock.",27,"ink")
    w.bar(self,28,551,834,s.progress/s.distance*100,"gold",5)
    scene.draw(self,28,307,834,230,s)
    local forecast=model.forecast(s)
    label(self,44,324,util.round(s.distance-s.progress).." km to the next landmark")
    w.panel(self,28,169,834,122)
    local main_label=s.mode=="traveling" and "Pause the wagon" or "Follow the road"
    local main_command=s.mode=="traveling" and "pause" or "resume"
    w.button(self,44,232,250,40,main_label,cmd(self,main_command),{primary=true,size=15,icon="trail"})
    w.button(self,306,232,162,40,(self.snapshot.settings.travel_speed or 1)==1 and "Speed: calm" or "Speed: brisk",cmd(self,"settings",{key="travel_speed"}),{key="travel_speed",size=13})
    w.button(self,480,232,170,40,"Pace: "..s.pace,function()
        local next={easy="steady",steady="hurried",hurried="easy"};self.perform("policy",{key="pace",value=next[s.pace]})
    end,{size=12})
    w.button(self,662,232,184,40,"Meals: "..s.rations,function()
        local next={sparse="normal",normal="generous",generous="sparse"};self.perform("policy",{key="rations",value=next[s.rations]})
    end,{size=12})
    label(self,44,209,"Base day: "..forecast.food.." food / "..forecast.progress.." km / "..forecast.effort.." haul energy, +"..forecast.recovery.." recovery. Crew and conditions can change this.")
    w.button(self,44,179,180,23,"Camp & recover",page(self,"camp"),{size=12,icon="rest"})
    w.button(self,236,179,180,23,"Request help",page(self,"return"),{size=12})
    label(self,440,189,"Space pauses. Every choice waits for you.")
    recent_log(self,28,145,834,3)
    if s.notice then w.text(self,28,58,s.notice,12,"gold",834) end
end
local function choices(self,title,body,options,kicker)
    label(self,28,611,kicker or "A MOMENT ON THE TRAIL")
    w.panel(self,28,140,834,450)
    w.text(self,50,554,title,25,"ink")
    w.text(self,50,519,body,15,"muted",786)
    local row_gap=#options>4 and 60 or 69
    for i,option in ipairs(options) do
        local y=410-(i-1)*row_gap
        w.button(self,50,y,790,39,option.label,option.fn,{primary=i==1,enabled=option.enabled~=false,size=14,key=option.key,icon=option.icon})
        w.text(self,59,y-14,option.detail or "",11,option.enabled==false and "red" or "muted")
    end
    recent_log(self,28,114,834,2)
end
local function event(self)
    local s=self.snapshot.run
    local definition=model.events.by_id[s.pending.id]
    local options={}
    for _,choice in ipairs(definition.choices) do
        local enabled,why=model.events.available(s,choice,self.snapshot.profile)
        local icon=choice.species and iconography.role(choice.species) or (choice.battle and "pressure" or (choice.days and "time" or (choice.recruit and "crew" or "journal")))
        if choice.cost and not choice.species and not choice.recruit then for _,key in ipairs({"food","coins","medicine","repairs"}) do if choice.cost[key] then icon=key;break end end end
        options[#options+1]={label=choice.label,enabled=enabled,detail=enabled and model.events.cost_text(s,choice) or why,fn=cmd(self,"choice",{id=choice.id}),key="event_"..choice.id,icon=icon}
    end
    choices(self,definition.title,definition.text,options,"DAY "..s.day.."  /  TRAVEL PAUSED")
end
local function landmark(self)
    local s=self.snapshot.run; local options={}; local spot=model.route[s.target]
    local body=spot.subtitle
    if s.target==2 then
        body="The meadow road is shorter and easier on the wagon. The woodland path offers roots, shelter, and more to discover."
        options={
            {label="Across the meadows",detail="27 km / open ground / reliable progress",fn=cmd(self,"leave",{branch="meadow"})},
            {label="Through the woodland",detail="30 km / slower going / rich foraging",fn=cmd(self,"leave",{branch="woodland"})},
            {label="Rest beneath the oak",detail="1 day + "..model.resources.daily_food(s).." food / recover condition and energy",fn=cmd(self,"rest")}}
    elseif s.target==3 then
        body="This is the only supply shop before Lantern Reach. The ferryman at Willowford charges 12 coins; leave some room in your purse."
        options={
            {label="Visit the supply counter",detail="Buy provisions, repair materials, and medicine",fn=page(self,"shop")},
            {label="Make a quiet camp",detail="Rest, forage, and repair before the next stretch",fn=page(self,"camp")},
            {label="Set out for Willowford",detail="28 km / marsh road / a river crossing ahead",fn=cmd(self,"leave")}}
    elseif s.target==4 then
        if s.flags.river_crossed then
            body="Your wagon rests on the far bank. The high country lies ahead."
            options={{label="Continue to Cairn Gate",detail="24 km / upland road",fn=cmd(self,"leave")},
                {label="Rest beside the river",detail="1 day + meals / recover before the climb",fn=cmd(self,"rest")}}
        else
            body="Recent rainfall: "..s.rainfall.." / 6. "..(s.rainfall>=4 and "The current is strong." or "The channel is passable, but cold.").." Crossing takes one day and today's meals."
            if not s.flags.river_inspected then
                options[#options+1]={label="Inspect the river",detail="Record conditions / no time or supplies / unlock research after this trip",fn=cmd(self,"river",{method="inspect"})}
            end
            options[#options+1]={label="Take the ferry",detail="12 coins + 1 day of meals / dependable crossing",enabled=s.coins>=12,fn=cmd(self,"river",{method="ferry"})}
            local method=model.resources.find(s,"reedskipper",22) and "swim" or ((model.resources.find(s,"brindlehorn",22) or model.resources.find(s,"slatewhorl",22)) and "anchor" or "rope")
            options[#options+1]={label=method=="swim" and "Secure a line with Reedskipper" or (method=="anchor" and "Anchor a line with your companion" or "Use the wagon's crossing ropes"),
                detail=(method~="rope" and "22 energy / " or "No creature assistance / ")..util.round(model.river_risk(s,method)*100).."% risk of wet supplies and damage",fn=cmd(self,"river",{method=method})}
            options[#options+1]={label="Wait and watch the water",detail="1 day + meals / rest; weather may improve or worsen",fn=cmd(self,"river",{method="wait"})}
        end
    elseif s.target==5 then
        body="The ridge is shorter but rough on the wheels. The sheltered gorge adds distance. Watch the date: the road closes on day 32."
        options={{label="Take the ridge road",detail="30 km / quick passage / more wagon wear",fn=cmd(self,"leave",{branch="ridge"})},
            {label="Follow the sheltered gorge",detail="35 km / slower, gentler travel",fn=cmd(self,"leave",{branch="gorge"})},
            {label="Prepare for the last stretch",detail="Camp, repair, and care for your companions",fn=page(self,"camp")}}
    end
    choices(self,spot.name,body,options,"LANDMARK "..s.target.." / 6")
end
local function camp(self)
    local s=self.snapshot.run;local forage=model.forage_preview(s);local food=model.resources.daily_food(s)
    local available=s.mode=="stopped" or s.mode=="landmark" or s.mode=="traveling"
    choices(self,"A little time to recover.","Every camp action uses one day and the crew's meals. Well-fed companions regain more strength. You can always request help.",{
        {label="Rest the whole crew",icon="rest",detail="1 day / "..food.." food / up to +25 energy and +8 condition",enabled=available,fn=cmd(self,"rest")},
        {label="Gather nearby provisions",icon="forage",detail=forage.closing and "The road closes tomorrow; no harvest can be brought back." or (forage.gross<=0 and "This stretch has been gathered clean." or "Review 1 day, meals, carrying room and "..(forage.net>=0 and "+" or "")..forage.net.." expected provisions."),enabled=available and forage.gross>0 and not forage.closing,fn=page(self,"forage"),key="gather_preview"},
        {label="Repair the wagon",icon="repairs",detail=s.wagon>=100 and "The wagon needs no repairs." or (s.repairs<1 and "Needs 1 repair material." or "1 day + meals + 1 repair material / +30 wagon condition"),enabled=available and s.repairs>0 and s.wagon<100,fn=cmd(self,"repair")},
        {label="Treat the traveler",icon="medicine",detail=s.traveler>=100 and "The traveler is already in good condition." or (s.medicine<1 and "Needs 1 medicine." or "1 day + meals + 1 medicine / +35 condition and rest"),enabled=available and s.medicine>0 and s.traveler<100,fn=cmd(self,"treat")}},"CAMP / THE CLOCK IS STOPPED")
    w.button(self,50,151,220,31,"Back to the journey",page(self,"trail"),{size=12,icon="trail"})
end
local function shop(self)
    local s=self.snapshot.run
    local can=s.mode=="landmark" and s.target==3
    choices(self,"Mossbell supply counter","Pack what the next stretch needs. Your wagon carries "..model.resources.weight(s).." / "..model.resources.capacity(s)..". Purchases do not pass time.",{
        {label="Ten provisions",icon="food",detail="6 coins / 10 load",enabled=can and s.coins>=6 and model.resources.weight(s)+10<=model.resources.capacity(s),fn=cmd(self,"buy",{item="food"})},
        {label="A bundle of repair materials",icon="repairs",detail="8 coins / 4 load",enabled=can and s.coins>=8 and model.resources.weight(s)+4<=model.resources.capacity(s),fn=cmd(self,"buy",{item="repairs"})},
        {label="Medicine and clean bandages",icon="medicine",detail="7 coins / 2 load",enabled=can and s.coins>=7 and model.resources.weight(s)+2<=model.resources.capacity(s),fn=cmd(self,"buy",{item="medicine"})},
        {label="Return to the outpost",icon="trail",detail="Review the road ahead",fn=page(self,"trail")}},"MOSSBELL / "..s.coins.." COINS")
end
local function crew(self)
    local s=self.snapshot.run
    label(self,28,611,"COMPANIONS / SMALL CREW, SHARED HISTORY")
    w.text(self,28,575,"Who you bring changes the road.",27,"ink")
    local can=s.mode=="preparation" or s.mode=="stopped" or s.mode=="landmark" or s.mode=="traveling"
    for i,c in ipairs(s.crew) do
        local idx=i;local def=model.species.defs[c.species];local y=391-(i-1)*156
        w.panel(self,28,y,834,143)
        w.sprite(self,c.species,94,y+74,128,c.condition<=0)
        w.text(self,169,y+113,c.name.." / "..def.name,19,"ink")
        label(self,169,y+88,c.temperament.." / Trust "..c.trust.." / Condition "..util.round(c.condition).." / Energy "..util.round(c.stamina))
        w.text(self,169,y+66,def.ability,12,"muted")
        w.button(self,169,y+15,145,30,"Duty: "..c.duty,cmd(self,"duty",{member=idx}),{enabled=can,size=12,key="duty"..idx})
        w.button(self,324,y+15,144,30,i==s.hauler and "Hauler" or "Assign haul",cmd(self,"hauler",{member=idx}),{enabled=can and def.draft,selected=i==s.hauler,size=12,key="haul"..idx,icon="haul"})
        w.button(self,478,y+15,170,30,"Treat (+35)",cmd(self,"treat",{member=idx}),{enabled=can and s.mode~="preparation" and s.medicine>0 and c.condition<100,size=12,key="treat"..idx})
        w.button(self,658,y+15,184,30,"Name & memories",function() self.detail=idx;self.open_page("companion") end,{size=12,key="detail"..idx})
    end
    if #s.crew<3 then w.text(self,28,75,"Make room for a friend you have not met yet.",14,"muted") end
end
local function companion(self)
    local s=self.snapshot.run;local c=s.crew[self.detail or 1]
    if not c then return end
    label(self,28,611,"A TRAVELING COMPANION")
    w.panel(self,28,90,834,493)
    w.sprite(self,c.species,164,443,190)
    w.text(self,304,517,c.name,30,"ink")
    w.text(self,304,481,model.species.defs[c.species].name.." / "..c.temperament,16,"muted")
    w.text(self,304,449,model.species.defs[c.species].ability,14,"muted",500)
    w.button(self,304,365,232,36,"Give a new name",function() self.edit={kind="name",member=self.detail or 1,value=c.name};self.redraw() end,{size=13})
    label(self,50,317,"THINGS YOU HAVE SHARED")
    if #c.memories==0 then w.text(self,50,279,"The first page is still blank.",15,"muted") end
    for i,memory in ipairs(c.memories) do w.text(self,50,285-(i-1)*26,memory,13,"ink") end
    w.button(self,50,111,200,34,"Back to the crew",page(self,"crew"),{size=13})
end
local function map(self)
    local s=self.snapshot.run
    label(self,28,611,"THE FERNWAKE ROAD / A FAMILIAR PATH, A DIFFERENT JOURNEY")
    w.text(self,28,575,"From orchard to upland.",28,"ink")
    w.panel(self,28,182,834,353)
    w.rect(self,90,372,704,3,"edge")
    for i,spot in ipairs(model.route) do
        local x=90+(i-1)*140
        local visited=i<s.target or (i==s.target and s.progress>=s.distance)
        w.rect(self,x-6,367,14,14,visited and "gold" or "muted")
        w.text(self,x-25,413,string.format("%02d",i),25,visited and "gold" or "muted")
        local first,last=spot.name:match("^(%S+)%s(.+)$")
        w.text(self,x-35,345,first or spot.name,13,"ink")
        if last then w.text(self,x-35,325,last,13,"ink") end
        label(self,x-35,299,visited and "REACHED" or (i==s.target and (s.mode=="result" and "TURNED BACK" or "NEXT STOP") or "AHEAD"))
    end
    label(self,59,475,"DEPARTURE: FERNWAKE    /    DELIVERY: LANTERN REACH")
    label(self,59,260,"Split Oak: "..(s.branches.first or "meadow or woodland"))
    label(self,439,260,"Cairn Gate: "..(s.branches.last or "ridge or gorge"))
    w.text(self,59,226,"Preferred arrival: day 26. The road closes on day 32.",14,"gold")
    w.text(self,28,141,"Rain affects the river. Rough roads wear the wagon. A crew that knows one route may surprise you on another.",15,"muted",834)
end
local function journal(self)
    local s=self.snapshot.run;local p=self.snapshot.profile
    label(self,28,611,"FIELD NOTES / KNOWLEDGE TRAVELS WITH YOU")
    w.text(self,28,575,"A record of the road.",28,"ink")
    w.panel(self,28,101,834,439)
    w.button(self,472,555,180,31,"This journey",function() self.journal_history=false;self.redraw() end,{selected=not self.journal_history,size=12,icon="journal"})
    w.button(self,662,555,200,31,"Past journeys",function() self.journal_history=true;self.redraw() end,{selected=self.journal_history,size=12,icon="trail"})
    if self.journal_history then
        if #p.history==0 then w.text(self,49,505,"Your first journey is still being written.",15,"muted") end
        for i=#p.history,1,-1 do
            local entry=p.history[i];local row=#p.history-i
            w.text(self,49,510-row*37,"Seed "..entry.seed.." / day "..entry.day.." / "..entry.outcome.." / cargo "..util.round(entry.cargo).."%",14,"ink")
            label(self,49,492-row*37,(entry.route.first or "No first branch").." / "..(entry.route.last or "No final branch"))
        end
    else
    local offset=self.journal_offset or 0
    local finish=math.max(1,#s.log-offset);local start=math.max(1,finish-10)
    for i=start,finish do
        local entry=s.log[i]
        if entry then w.text(self,49,515-(i-start)*33,"Day "..entry.day.."  "..entry.text,12,"ink",790) end
    end
    w.button(self,49,117,180,29,"Earlier notes",function() self.journal_offset=math.min(math.max(0,#s.log-11),offset+11);self.redraw() end,{size=12,enabled=start>1})
    w.button(self,239,117,180,29,"Latest notes",function() self.journal_offset=0;self.redraw() end,{size=12,enabled=offset>0})
    end
    local known=0;for _ in pairs(p.discoveries) do known=known+1 end
    w.button(self,650,117,191,29,"Symbol guide",page(self,"symbols"),{key="symbol_guide",size=12,icon="journal"})
    label(self,28,70,known.." species recorded / "..#p.history.." recent expeditions / "..(p.covered and "covered wagon researched" or "study and cross Willowford for a wagon design"))
end
local function settings(self)
    local s=self.snapshot.run
    choices(self,"Make yourself comfortable.","The expedition is saved after every completed day and decision. Menus pause travel. Calm speed takes 20 seconds per day; brisk speed takes 2.5.",{
        {label="Sound: "..(self.snapshot.settings.sound and "on" or "off"),detail="Quiet feedback for decisions and arrivals",fn=cmd(self,"settings",{key="sound"})},
        {label="Motion: "..(self.snapshot.settings.motion and "gentle" or "reduced"),detail="Stops ambient movement when reduced",fn=cmd(self,"settings",{key="motion"})},
        {label="Travel view: "..((self.snapshot.settings.travel_speed or 1)==1 and "calm" or "brisk"),detail="Remembered between visits; travel pace and daily costs stay the same",fn=cmd(self,"settings",{key="travel_speed"}),key="travel_speed",icon="time"},
        {label="Save this moment",detail="Save now; it is safe to close the window afterward",fn=function() self.save_now();self.redraw() end},
        {label="Expedition seed: "..s.seed,detail=s.mode=="preparation" and "Change the seed before leaving the depot" or "Replay this seed from the result screen",enabled=s.mode=="preparation",key="settings_seed",fn=function() self.edit={kind="seed",value=tostring(s.seed)};self.redraw() end}},"OPTIONS")
end
local function result(self)
    local s=self.snapshot.run;local p=self.snapshot.profile
    label(self,28,611,"EXPEDITION COMPLETE / SEED "..s.seed)
    w.text(self,28,570,titles[s.outcome],30,"ink")
    scene.draw(self,28,307,834,230,s)
    w.text(self,28,279,s.ending,16,"ink",834)
    w.text(self,28,221,"Day "..s.day.." / Cargo "..util.round(s.cargo).."% / "..#s.crew.." companions home",15,"gold")
    w.text(self,28,185,"Your companions, discoveries, and memories stay with you. Everyone recovers before the next departure.",13,"muted",834)
    w.button(self,28,100,407,45,"Plan another journey",cmd(self,"new",{seed=s.seed+1},"trail"),{primary=true,size=16})
    w.button(self,453,100,409,45,"Replay this seed",cmd(self,"new",{seed=s.seed},"trail"),{size=15})
    label(self,28,69,p.covered and "Depot design available: covered wagon / less capacity, better rain protection" or "Try a different crew, or investigate Willowford to learn a wagon design.")
end
local function debug(self)
    local s=self.snapshot.run
    label(self,28,611,"DEVELOPER CONTROLS / F3 TO CLOSE")
    w.text(self,28,575,"Explore the authored encounters.",25,"ink")
    label(self,28,538,"Forces a test event. Only available while traveling or stopped.")
    local row=0
    for _,event in ipairs(model.events.defs) do
        if event.choices then
            local id=event.id;row=row+1
            local x=28+((row-1)%2)*425;local y=477-math.floor((row-1)/2)*52
            w.button(self,x,y,409,39,event.title,function() self.force_event(id) end,{size=12,key="debug"..id})
        end
    end
    w.button(self,28,80,409,35,"Restore supplies & condition",function() self.debug_resupply() end,{size=12})
    w.button(self,453,80,409,35,"Advance one travel day",function()
        if s.mode=="stopped" then self.perform("resume") end
        self.perform("step")
    end,{size=12})
end
local function overlay(self)
    if self.edit then
        local edit=self.edit
        w.rect(self,0,0,1280,720,"dark",0.88);w.panel(self,300,240,680,230)
        w.text(self,330,433,edit.kind=="seed" and "Choose an expedition seed" or "Name your companion",24,"ink")
        w.rect(self,330,337,620,60,"dark");w.text(self,350,368,edit.value.."_",25,"gold")
        label(self,330,313,"Type a name or number. Tab selects; Enter activates; Escape cancels.")
        w.button(self,330,257,295,37,"Keep this",function() self.finish_edit() end,{primary=true,size=14})
        w.button(self,641,257,309,37,"Cancel",function() self.edit=nil;self.redraw() end,{size=14})
    elseif self.save_blocked then
        w.rect(self,0,0,1280,720,"dark",0.94);w.panel(self,300,240,680,230)
        w.text(self,330,428,"The saved journey needs recovery.",23,"ink")
        w.text(self,330,384,"Both save files failed validation. Starting fresh replaces the active depot. You can close the game to preserve the files for inspection.",15,"muted",610)
        w.button(self,330,260,620,42,"Start a fresh depot",function() self.save_blocked=false;self.save_now();self.redraw() end,{primary=true,size=15})
    end
end
function M.draw(self)
    w.begin(self);w.rect(self,0,0,1280,720,"bg");header(self)
    local s=self.snapshot.run
    if self.page=="trail" and s.mode=="preparation" then preparation(self)
    else
        sidebar(self)
        if self.page=="crew" then crew(self)
        elseif self.page=="companion" then companion(self)
        elseif self.page=="map" then map(self)
        elseif self.page=="journal" then journal(self)
        elseif self.page=="symbols" then symbol_guide.draw(self)
        elseif self.page=="forage" then gathering.draw(self)
        elseif self.page=="settings" then settings(self)
        elseif self.page=="camp" then camp(self)
        elseif self.page=="shop" then shop(self)
        elseif self.page=="debug" then debug(self)
        elseif self.page=="return" then choices(self,"Bring everyone home.","Requesting assistance ends this delivery. Your companions and discoveries return with you; you can prepare another journey right away.",{
            {label="Keep traveling",detail="Return to the stopped wagon",fn=page(self,"trail")},
            {label="Request assistance and return home",detail="End this expedition; retain discoveries and companions",fn=cmd(self,"return",nil,"trail")}},"A WAY HOME")
        elseif s.mode=="event" then event(self)
        elseif s.mode=="landmark" then landmark(self)
        elseif s.mode=="combat_select" then auto_battle.select(self)
        elseif s.mode=="combat" then
            if model.combat.automatic(s.battle) then auto_battle.draw(self) else legacy_battle.draw(self) end
        elseif s.mode=="combat_result" then auto_battle.result(self)
        elseif s.mode=="result" then result(self)
        else travel(self) end
    end
    if self.save_blocked or self.edit then self.buttons={};overlay(self) end
    w.finish(self)
end
return M
