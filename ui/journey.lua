local w=require "ui.widgets"
local model=require "simulation.expedition"
local map=require "presentation.route_map"
local world=require "presentation.overworld"
local util=require "simulation.util"
local M={}
local function cmd(self,id,args) return function() self.map_detail=nil;self.journey_details=nil;self.perform(id,args,"trail") end end
local function page(self,id) return function() self.open_page(id) end end
local function short(text,n) return require("presentation.ambush").short(text,n) end
function M.supports(self)
    local s=self.snapshot.run
    return (self.page=="trail" or self.page=="map") and
        (s.mode=="stopped" or s.mode=="traveling" or s.mode=="landmark" or s.mode=="event" or s.road_story or self.journey_motion or (s.mode=="preparation" and self.snapshot.profile.collection))
end
local function supplies(self)
    local s=self.snapshot.run;local f=model.forecast(s)
    local stats={{"food",s.food,"Food"},{"coins",s.coins},{"wagon",util.round(s.wagon).."%"},
        {"cargo",util.round(s.cargo).."%"},{"condition",util.round(s.traveler).."%","You"},
        {"repairs",s.repairs},{"medicine",s.medicine}}
    for i,v in ipairs(stats) do
        local x=28+(i-1)*148
        w.reading(self,x,611,v[1],v[2],{label=v[3],size=13,icon_size=24})
    end
    w.reading(self,1075,613,"time",s.day.." / 26",{label="Day",size=14})
    w.text(self,1109,594,"Closes D32",10,"muted")
    w.text(self,28,590,f.days.." food days / "..model.resources.daily_food(s).." meals daily",10,"muted")
end
local function crew(self)
    local s=self.snapshot.run
    for i=1,4 do
        local x=28+(i-1)*308;local c=s.crew[i]
        w.rect(self,x,55,298,98,"panel");w.rect(self,x,151,298,2,c and w.tint(require("ui.iconography").role(c.species)) or "edge")
        if c then
            local prep=s.mode=="preparation"
            w.sprite(self,c.species,x+37,103,70,c.condition<=0)
            w.button(self,x+79,120,prep and 146 or 208,25,short(c.name,prep and 11 or 15)..(c.uid and " #"..c.uid or ""),function() self.detail=i;self.open_page("companion") end,{key="journey_member"..i,size=12})
            if prep then w.button(self,x+231,120,56,25,"Store",cmd(self,"collect_select",{uid=c.uid}),{key="store_"..c.uid,size=10}) end
            w.reading(self,x+81,105,"stamina",util.round(c.stamina),{size=11,icon_size=12})
            w.bar(self,x+193,102,91,c.stamina,w.tint("stamina"),4)
            w.reading(self,x+81,87,"condition",util.round(c.condition),{size=11,icon_size=12})
            w.bar(self,x+193,84,91,c.condition,w.tint("condition"),4)
            w.text(self,x+81,67,c.condition<=0 and "NEEDS CARE" or (c.stamina<=0 and "EXHAUSTED" or (i==s.hauler and "Hauling" or c.duty)),10,(c.condition<=0 or c.stamina<=0) and "red" or "muted")
        elseif s.mode=="preparation" then
            w.button(self,x+30,88,238,36,"Choose companion",page(self,"collection"),{key="choose_slot"..i,icon="collection",size=12})
        else w.reading(self,x+78,104,"crew",nil,{label="Open party slot",size=12}) end
    end
end
local panel
local function preparation(self)
    local s,p=self.snapshot.run,self.snapshot.profile
    panel(self,"Pack for Lantern Reach","FERNWAKE / ORCHARD DELIVERY")
    w.text(self,886,505,"Due D26 / road closes D32",12,"gold")
    for i,id in ipairs({"food","repairs","medicine"}) do
        local item=model.resources.goods[id];local y=431-(i-1)*58
        w.reading(self,886,y+23,id,s[id],{label=id=="food" and "Food" or nil,size=14})
        w.text(self,920,y+3,item.price.." coins / "..item.weight.." load",10,"muted")
        w.button(self,1092,y+5,60,32,"-"..item.amount,cmd(self,"sell",{item=id}),{key="sell_"..id,size=13,enabled=s[id]>=item.amount})
        w.button(self,1162,y+5,74,32,"+"..item.amount,cmd(self,"buy",{item=id}),{key="buy_"..id,size=13,enabled=s.coins>=item.price and model.resources.weight(s)+item.weight<=model.resources.capacity(s)})
    end
    w.button(self,886,267,168,31,"Open wagon",cmd(self,"wagon",{id="standard"}),{selected=s.wagon_type=="standard",size=12})
    w.button(self,1066,267,170,31,"Covered",cmd(self,"wagon",{id="covered"}),{selected=s.wagon_type=="covered",enabled=p.covered,size=12})
    w.text(self,886,252,p.covered and "Canvas: less load / rain protection" or "Inspect Willowford to unlock canvas",10,"muted")
end
local function button(self,y,label,detail,fn,options)
    options=options or {};options.size=options.size or 12
    w.button(self,886,y,350,32,label,fn,options)
    if detail and detail~="" then w.text(self,890,y-6,detail,10,options.enabled==false and "red" or "muted",340) end
end
panel=function(self,title,kicker)
    w.rect(self,870,232,382,345,"dark");w.rect(self,870,574,382,3,w.tint(kicker=="WILDLIFE" and "scout" or "flag"))
    w.text(self,886,558,kicker or "STOPPED",10,"gold")
    w.text(self,886,533,short(title,34),18,"ink")
end
local function event(self)
    local s=self.snapshot.run;local def=model.events.by_id[s.pending.id]
    panel(self,def.title,def.kind=="encounter" and "WAGON ENCOUNTER" or "WILDLIFE / ROADSIDE")
    if self.journey_details then
        w.text(self,886,477,def.text,14,"ink",345)
        button(self,250,"Back to choices",nil,function() self.journey_details=nil;self.redraw() end,{key="event_details_back"})
        return
    end
    w.button(self,1096,548,140,22,"Read the scene",function() self.journey_details=true;self.redraw() end,{key="event_details",size=10})
    w.text(self,886,509,short(def.text:match("^.-%.") or def.text,52),11,"muted")
    local options={}
    for _,c in ipairs(def.choices) do
        local enabled,why=model.events.available(s,c,self.snapshot.profile)
        local icon=c.species and require("ui.iconography").role(c.species) or (c.battle and "pressure" or c.recruit and "crew" or c.days and "time" or "journal")
        if c.cost and not c.species and not c.recruit then for _,id in ipairs({"food","coins","medicine","repairs"}) do if c.cost[id] then icon=id;break end end end
        options[#options+1]={label=c.label,detail=enabled and model.events.cost_text(s,c) or why,fn=cmd(self,"choice",{id=c.id}),icon=icon,key="event_"..c.id,enabled=enabled}
    end
    if def.kind=="encounter" then options[#options+1]={label="Lead the crew away",detail=model.combat.withdraw_text(def.id,s),fn=cmd(self,"withdraw"),key="event_withdraw",icon="trail"} end
    for i,v in ipairs(options) do button(self,468-(i-1)*68,v.label,v.detail,v.fn,{key=v.key,icon=v.icon,enabled=v.enabled,primary=i==1}) end
end
local function fork(self)
    local s=self.snapshot.run;local report=model.trail_reports.get(s)
    panel(self,model.route[s.target].name,"CHOOSE A PATH ON THE MAP")
    local facts={meadow="normal speed / 10 food gathering",woodland="10% slower / 10 food gathering",ridge="5% faster / +0.6 wagon wear daily",gorge="10% slower / no ridge wear"}
    for i,p in ipairs(report.routes) do
        local y=478-(i-1)*91
        w.reading(self,886,y,map.branches[p.id].icon,nil,{label=map.branches[p.id].name,size=17})
        w.text(self,886,y-22,p.distance.." km / "..facts[p.id],11,"ink",346)
        if p.id=="ridge" then w.text(self,886,y-42,"Hurried: -2 Cargo each day",11,"red") end
    end
    w.text(self,886,320,s.target==2 and (s.weather.." now / future weather unknown") or "No shops ahead / road closes D32",11,"gold")
    local early=s.target==2
    button(self,273,early and "Rest beneath the oak" or "Prepare for the last stretch",early and "1 day / "..model.resources.daily_food(s).." food" or "Rest, repairs & gathering",early and cmd(self,"rest") or page(self,"camp"),{icon="rest",key=early and "Rest beneath the oak" or "Prepare for the last stretch"})
    w.button(self,1113,548,123,22,"Full report",function() self.open_page("trail_report") end,{size=10,key="full_trail_report"})
end
local function landmark(self)
    local s=self.snapshot.run
    if #map.options(s)>0 then return fork(self) end
    panel(self,model.route[s.target].name,s.target==3 and "LAST SUPPLY SHOP" or "RIVER CROSSING")
    if s.target==3 then
        button(self,470,"Supply counter","Last shop / keep 12 coins for the ferry",page(self,"shop"),{key="Visit the supply counter",icon="food",primary=true})
        button(self,402,"Camp","Rest, gather, repair",page(self,"camp"),{key="Make a quiet camp",icon="rest"})
        button(self,334,s.wagon_practice and "Resume Mara's drill" or "Mara's wagon drill","-6 Energy each / cargo & health safe",function() require("services.ambush_controller").open_practice(self,self.practice_writer) end,{key="wagon_practice",icon="crew",enabled=require("simulation.wagon_practice").available(s)})
        button(self,266,"Set out for Willowford","28 km / marsh / river crossing",cmd(self,"leave"),{key="Set out for Willowford",icon="trail"})
    elseif s.flags.river_crossed then
        button(self,470,"Continue to Cairn Gate","24 km / upland",cmd(self,"leave"),{key="Continue to Cairn Gate",icon="trail",primary=true})
        button(self,402,"Rest beside the river","1 day / "..model.resources.daily_food(s).." food",cmd(self,"rest"),{key="Rest beside the river",icon="rest"})
    else
        w.text(self,886,493,"Rain "..s.rainfall.."/6 / "..(s.rainfall>=4 and "Strong current" or "Passable").." / crossing: 1 day + meals",10,"gold")
        local y=450
        if not s.flags.river_inspected then
            button(self,y,"Inspect the river","Free / unlock research after this trip",cmd(self,"river",{method="inspect"}),{key="Inspect the river",icon="scout"});y=y-62
        end
        button(self,y,"Take the ferry","-12 coins / 1 day + meals / dependable",cmd(self,"river",{method="ferry"}),{key="Take the ferry",icon="coins",enabled=s.coins>=12});y=y-62
        local method=model.crossing_helper(s,"swim") and "swim" or (model.crossing_helper(s,"anchor") and "anchor" or "rope")
        local _,_,effort=model.crossing_helper(s,method)
        button(self,y,method=="swim" and "Reedskipper's line" or method=="anchor" and "Companion's anchor" or "Wagon ropes",(effort and effort.." Energy / " or "")..util.round(model.river_risk(s,method)*100).."% risk: wet supplies + damage",cmd(self,"river",{method=method}),{key="river_line",icon="water"});y=y-62
        button(self,y,"Wait for the water","1 day + meals / weather may worsen",cmd(self,"river",{method="wait"}),{key="Wait and watch the water",icon="time"})
    end
end
local function details(self)
    local s=self.snapshot.run;local p=map.places[self.map_detail]
    panel(self,p.name,map.reached(s,self.map_detail) and "REACHED" or "AHEAD")
    local notes={"Wayhome Commons / your collection lives here.","Meadow or woodland / two roads to Mossbell.","Final supply shop / food, repairs, medicine.","River crossing / ferry or companion help.","Last shelter / choose ridge or gorge.","Deliver orchard cuttings by day 26. Road closes day 32."}
    w.reading(self,886,475,p.icon,nil,{label=p.note or model.route[self.map_detail].terrain,size=16})
    w.text(self,886,438,notes[self.map_detail],16,"ink",345)
    button(self,260,"Back to the road",nil,function() self.map_detail=nil;self.redraw() end,{key="map_close",icon="map"})
end
function M.draw(self)
    local s=self.snapshot.run;local transit=self.journey_motion~=nil
    supplies(self)
    local prep=s.mode=="preparation"
    local side=not transit and (self.map_detail or prep or s.mode=="event" or s.mode=="landmark" or s.road_story)
    world.draw(self,28,232,side and 820 or 1224,345)
    if side then
        if self.map_detail then details(self)
        elseif prep then preparation(self)
        elseif s.road_story then
            panel(self,"The road remembers","AN EARLIER CHOICE")
            w.text(self,886,485,s.road_story,14,"ink",345)
            button(self,260,"Continue the journey","Reading costs no time",cmd(self,"ack_story"),{key="story_continue",icon="trail",primary=true})
        elseif s.mode=="event" then event(self)
        else landmark(self) end
    else
        w.rect(self,40,545,360,24,"dark")
        w.reading(self,48,557,"flag",math.max(0,util.round(s.distance-s.progress)).." km",{label=model.route[s.target].name,size=12,icon_size=12})
        w.text(self,1034,557,s.weather:upper().." / "..(transit and "ON THE MOVE" or s.mode=="traveling" and "TRAVELING" or "STOPPED"),10,"ink")
    end
    if s.notice or s.flags.axle_lashed then
        w.rect(self,40,239,side and 796 or 1200,43,"dark")
        w.text(self,50,273,s.notice or "Loose axle: -6 Wagon on rough travel. Repair at camp.",12,"gold",side and 775 or 1180)
    end
    if prep then
        w.button(self,28,183,216,36,"Begin journey",cmd(self,"depart"),{key="BEGIN THE JOURNEY",primary=true,icon="trail",size=14})
        w.button(self,254,183,180,36,"Collection / "..#self.snapshot.profile.collection,page(self,"collection"),{key="open_collection",icon="collection",size=12})
        w.button(self,444,183,156,36,"Work items",page(self,"work_items"),{key="open_items",icon="capacity",size=12})
        w.button(self,610,183,142,36,"Journal aims",page(self,"aims"),{key="open_aims",icon="journal",size=12})
        local p=self.snapshot.profile
        if p.start_mode=="discovery" and p.last_committed==0 and s.id==1 then
            for i,id in ipairs({"brindlehorn","reedskipper"}) do w.button(self,762+(i-1)*250,183,240,36,model.species.defs[id].name,cmd(self,"starter",{species=id}),{key="select_"..id,selected=p.starter==id,icon="haul",size=12}) end
        else w.reading(self,900,201,"crew",#s.crew.." / 4",{label="Party",size=14}) end
        w.text(self,28,167,"Choose up to four / at least one hauler / reserves stay at Wayhome Commons",11,"muted")
        w.text(self,900,167,"Load "..model.resources.weight(s).." / "..model.resources.capacity(s),11,"muted")
        crew(self);return
    end
    local running=s.mode=="traveling"
    local travel_allowed=(s.mode=="traveling" or s.mode=="stopped") and not s.road_story and not transit
    w.button(self,28,183,216,36,transit and "Arriving..." or running and "Pause" or "Travel",cmd(self,running and "pause" or "resume"),{key=running and "Pause the wagon" or "Follow the road",primary=true,icon="trail",enabled=travel_allowed})
    w.button(self,254,183,145,36,(self.snapshot.settings.travel_speed or 1)==1 and "Calm" or "Brisk",cmd(self,"settings",{key="travel_speed"}),{key="travel_speed",icon="time",size=12,enabled=not transit})
    w.button(self,409,183,161,36,"Pace: "..s.pace,function() local next={easy="steady",steady="hurried",hurried="easy"};self.perform("policy",{key="pace",value=next[s.pace]}) end,{key="map_pace",size=12,enabled=travel_allowed})
    w.button(self,580,183,171,36,"Meals: "..s.rations,function() local next={sparse="normal",normal="generous",generous="sparse"};self.perform("policy",{key="rations",value=next[s.rations]}) end,{key="map_rations",size=12,icon="food",enabled=travel_allowed})
    w.button(self,761,183,139,36,"Camp",page(self,"camp"),{key="map_camp",icon="rest",size=12,enabled=not transit and (travel_allowed or s.mode=="landmark")})
    w.button(self,910,183,172,36,"Wildlife nearby",page(self,"tracking"),{key="open_tracking",icon="scout",size=12,enabled=not transit and (travel_allowed or s.mode=="landmark")})
    w.button(self,1092,183,160,36,"Crew & care",page(self,"crew"),{key="report_crew",icon="crew",size=12,enabled=not transit})
    local f=model.forecast(s)
    w.text(self,28,167,"Per day: -"..f.food.." Food / "..f.progress.." km base / -"..f.effort.." Haul energy / +"..f.recovery.." Recovery",10,"muted")
    w.text(self,762,167,"Load "..model.resources.weight(s).."/"..model.resources.capacity(s).." / weather & crew affect travel",10,"muted")
    crew(self)
    w.button(self,1120,25,132,22,"Request help",page(self,"return"),{key="map_help",size=10,enabled=not transit})
end
return M
