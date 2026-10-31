local w=require "ui.widgets"
local model=require "simulation.expedition"
local util=require "simulation.util"
local M={}
function M.draw(self)
    local s=self.snapshot.run;local p=model.forage_preview(s)
    local available=s.mode=="stopped" or s.mode=="traveling" or s.mode=="landmark"
    w.text(self,28,611,"GATHERING / REVIEW THE DAY",12,"muted")
    w.text(self,28,575,"What the ground can spare.",27,"ink")
    w.text(self,28,541,s.terrain:gsub("^%l",string.upper).." / "..model.route[s.target].name.." / Visits: "..p.count,14,"muted")
    w.rect(self,28,518,834,1,"edge")
    w.reading(self,28,487,"time","1 day",{label="Cost"})
    w.reading(self,453,487,"stamina",p.effort,{label="Energy spent"})
    local helper=p.member and (p.member.name.." digs / "..util.round(p.member.stamina).." energy") or "Hand gathering / no crew energy cost"
    w.text(self,28,451,helper,14,"ink")
    w.text(self,28,427,"Loamling: "..model.resources.effort(s,"loamling",18,"forage").." energy, condition >0 / Yield: -5 per visit",12,"muted")
    w.reading(self,28,383,"food",p.gross,{label="Found"})
    w.reading(self,310,383,"food",p.packed,{label="Can pack"})
    w.reading(self,592,383,"food","-"..p.meals,{label="Meals"})
    w.reading(self,28,340,"capacity",p.space,{label="Room after meals"})
    w.text(self,453,340,p.packed<p.gross and ((p.gross-p.packed).." left behind") or "All food fits",13,p.packed<p.gross and "red" or "muted")
    w.rect(self,28,313,834,1,"edge")
    w.reading(self,28,279,"food",(p.net>=0 and "+" or "")..p.net,{label="Expected net",size=22})
    w.text(self,28,245,"Net = packed - meals. Meals come first.",13,"muted")
    local warning=p.closing and "The road closes tomorrow. There is no time to bring a harvest back."
        or (p.meals<p.need and ("Only "..p.meals.." of "..p.need.." meals available: hunger weakens the crew before gathering.")
        or (p.gross<=0 and "This stretch has been gathered clean. Move on to find new ground."
        or "Weather and daily recovery apply."))
    w.text(self,28,209,warning,14,(p.closing or p.meals<p.need) and "red" or "muted",834)
    w.button(self,28,114,409,43,"Gather for one day",function() self.perform("forage",nil,"camp") end,{key="gather_confirm",primary=true,icon="forage",enabled=available and p.gross>0 and not p.closing})
    w.button(self,453,114,409,43,"Back to camp",function() self.open_page("camp") end,{key="gather_back",icon="rest"})
end
return M
