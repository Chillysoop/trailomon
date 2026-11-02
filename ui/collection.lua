local w=require "ui.widgets"
local model=require "simulation.expedition"
local collection=require "simulation.collection"
local icons=require "ui.iconography"
local M={}
local function shown_name(c) return require("presentation.ambush").short(c.name,14).." #"..c.uid end
local function open(self) self.collection_page=1;self.open_page("collection") end
function M.departure(self)
    local s,p=self.snapshot.run,self.snapshot.profile
    w.text(self,28,611,"FERNWAKE / DEPARTURE "..s.seed,12,"muted")
    w.text(self,28,572,"Choose your traveling party.",30,"ink")
    w.reading(self,28,537,"crew",#s.crew.." / 4",{label="Party",size=15})
    w.reading(self,230,537,"collection",#p.collection,{size=15})
    w.text(self,28,499,"At least 1 hauler. Only your party eats and fights.",13,"muted")
    w.button(self,594,487,268,30,"Journal aims",function() self.open_page("aims") end,{key="open_aims",size=12,icon="journal"})
    for i=1,4 do
        local c=s.crew[i];local y=390-(i-1)*85
        w.panel(self,28,y,834,75)
        if c then
            local uid=c.uid
            w.sprite(self,c.species,70,y+39,70)
            w.text(self,118,y+51,shown_name(c),18,"ink")
            w.text(self,118,y+27,model.species.defs[c.species].name,12,"muted")
            w.reading(self,360,y+51,icons.role(c.species),nil,{label=model.species.defs[c.species].draft and "Can haul" or "Companion",size=12})
            local content=require "content.ambush";local kit=content.kits[content.by_species[c.species]]
            w.text(self,360,y+27,kit.skill,12,"muted")
            w.button(self,709,y+21,133,33,"Store",function() self.perform("collect_select",{uid=uid}) end,{key="store_"..uid,size=13,icon="collection"})
        else
            w.reading(self,54,y+43,"crew",nil,{label="Empty party slot",size=16})
            w.button(self,612,y+21,230,33,"Choose companion",function() open(self) end,{key="choose_slot"..i,size=13,icon="collection"})
        end
    end
    w.button(self,28,78,275,36,"Collection / "..#p.collection,function() open(self) end,{key="open_collection",icon="collection",size=14})
    local starter=p.start_mode=="discovery" and p.last_committed==0 and s.id==1
    if starter then
        for i,id in ipairs({"brindlehorn","reedskipper"}) do
            w.button(self,320+(i-1)*276,78,266,36,model.species.defs[id].name,function() self.perform("starter",{species=id}) end,{key="select_"..id,selected=p.starter==id,size=13,icon="haul"})
        end
    else w.text(self,326,98,"Reserves wait at the depot. No collection limit.",13,"muted") end
end
function M.draw(self)
    local s,p=self.snapshot.run,self.snapshot.profile
    w.text(self,28,611,"FERNWAKE COLLECTION / INDIVIDUAL COMPANIONS",12,"muted")
    w.reading(self,28,575,"collection",#(p.collection or {}),{label="Collected",size=27})
    w.reading(self,340,575,"crew",#s.crew.." / 4",{label="Party",size=20})
    w.text(self,28,542,s.mode=="preparation" and "Choose up to four. Store one first if the party is full." or "Browse freely. Change your party at Fernwake before departure.",13,"muted")
    local active={};for _,c in ipairs(s.crew) do active[c.uid]=c end
    local filter=self.collection_filter or "all";local rows={}
    for _,c in ipairs(p.collection or {}) do
        if filter=="all" or (filter=="party" and active[c.uid]) or (filter=="depot" and not active[c.uid]) then rows[#rows+1]=active[c.uid] or c end
    end
    for i,f in ipairs({{"all","All"},{"party","Party"},{"depot","At depot"}}) do
        w.button(self,28+(i-1)*150,480,140,34,f[2],function() self.collection_filter=f[1];self.collection_page=1;self.redraw() end,{key="collection_"..f[1],selected=filter==f[1],size=13})
    end
    local pages=math.max(1,math.ceil(#rows/6));local page=math.max(1,math.min(self.collection_page or 1,pages));self.collection_page=page
    for i=(page-1)*6+1,math.min(page*6,#rows) do
        local c=rows[i];local uid=c.uid;local y=414-((i-1)%6)*55
        w.panel(self,28,y,834,49);w.sprite(self,c.species,61,y+26,48)
        w.text(self,94,y+32,shown_name(c),15,"ink");w.text(self,94,y+14,model.species.defs[c.species].name,11,"muted")
        w.reading(self,352,y+30,icons.role(c.species),nil,{label=model.species.defs[c.species].draft and "Hauler" or "Companion",size=12,icon_size=12})
        w.text(self,503,y+29,active[uid] and "IN PARTY" or "AT DEPOT",11,"muted")
        w.button(self,677,y+8,166,33,active[uid] and "Store" or "Take along",function() self.perform("collect_select",{uid=uid}) end,{key="collection_select_"..uid,enabled=s.mode=="preparation" and (active[uid]~=nil or #s.crew<4),size=12,icon=active[uid] and "collection" or "crew"})
    end
    if #rows==0 then w.text(self,28,430,"No companions here yet.",16,"muted") end
    w.button(self,28,79,190,34,"Back to journey",function() self.open_page("trail") end,{key="collection_back",size=12,icon="trail"})
    w.button(self,464,79,120,34,"Previous",function() self.collection_page=page-1;self.redraw() end,{key="collection_prev",enabled=page>1,size=12})
    w.text(self,605,100,page.." / "..pages,12,"ink")
    w.button(self,742,79,120,34,"Next",function() self.collection_page=page+1;self.redraw() end,{key="collection_next",enabled=page<pages,size=12})
end
return M
