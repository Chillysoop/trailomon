local w=require "ui.widgets"
local aims=require "simulation.journal_aims"
local M={}
function M.draw(self)
    w.text(self,28,611,"OPTIONAL JOURNAL AIMS / RECORDED ACROSS JOURNEYS",12,"muted")
    w.text(self,28,575,"A reason to take another road.",27,"ink")
    w.panel(self,28,129,834,418)
    for i,row in ipairs(aims.rows(self.snapshot)) do
        local y=518-(i-1)*132
        w.reading(self,49,y,row.icon,nil,{label=row.title,size=21})
        w.text(self,687,y,row.status,12,row.done and "sage" or "gold")
        w.text(self,83,y-26,row.description,14,"ink",744)
        w.text(self,83,y-78,row.note,12,"muted",744)
        if i<3 then w.rect(self,49,y-108,792,1,"edge") end
    end
    w.button(self,28,78,254,34,"Back to the journal",function() self.open_page("journal") end,{key="aims_back",size=13,icon="journal"})
    w.text(self,307,94,"All three track automatically. Accomplishments carry no stat rewards.",12,"muted")
end
return M
