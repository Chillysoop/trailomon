local w=require "ui.widgets"
local tracking=require "simulation.tracking"
local discovery=require "simulation.discovery"
local species=require "content.species"
local route=require "content.route"
local M={}
function M.draw(self)
    local s=self.snapshot.run;local p=tracking.preview(self.snapshot);local invitation=discovery.invitation(self.snapshot)
    w.text(self,28,611,"WILDLIFE / OPTIONAL DETOUR",12,"muted")
    w.text(self,28,575,"What lives beside this road.",27,"ink")
    w.reading(self,28,539,"flag",nil,{label=route[s.target].name.." / "..s.terrain,size=14})
    w.panel(self,28,369,834,144)
    w.text(self,49,483,invitation and (species.defs[invitation].name.." is waiting nearby.") or "No companion waiting here.",20,"ink")
    w.text(self,49,451,invitation and "Meeting is free. Invitation: 4 provisions / needs a crew space." or "Discovery invitations: Split Oak and Willowford.",12,"muted")
    w.button(self,49,389,792,37,invitation and ("Meet "..species.defs[invitation].name) or "No invitation here",function() self.perform("meet_wild",nil,"trail") end,{key="meet_wild",enabled=invitation~=nil,icon="crew",size=14})
    w.panel(self,28,143,834,208)
    w.reading(self,49,320,"scout",nil,{label=p.sign,size=21})
    w.text(self,49,290,p.name.." / unconfirmed tracks",13,"muted")
    w.reading(self,49,258,"time","1 day",{label="Search",size=14})
    w.reading(self,370,258,"food","-"..p.meals,{label="Meals",size=14})
    w.text(self,49,230,p.reason or "Tracks may end at empty shelter. Weather and daily recovery apply.",12,p.available and "muted" or "gold",780)
    w.button(self,49,164,792,39,"Follow these tracks",function() self.perform("follow_tracks",nil,"trail") end,{key="follow_tracks",enabled=p.available,primary=true,icon="scout",size=14})
    w.button(self,28,78,405,34,"Pass / back to the road",function() self.open_page("trail") end,{key="tracks_back",icon="trail",size=13})
    w.button(self,447,78,415,34,"Species field guide",function() self.open_page("field_guide") end,{key="tracks_guide",icon="journal",size=13})
end
return M
