local w=require "ui.widgets"
local landscape=require "presentation.landscape"
local model=require "simulation.expedition"
local M={}
function M.draw(self,report)
    local s=self.snapshot.run
    w.text(self,28,611,"LANDMARK "..s.target.." / 6  /  TRAVEL PAUSED",12,"muted")
    w.text(self,28,578,model.route[s.target].name.." / trail report",27,"ink")
    landscape.draw(self,w,28,476,834,72,s)
    w.text(self,28,460,report.source,12,"gold")
    w.text(self,28,438,report.outlook,14,"ink",834)
    w.text(self,28,395,report.reminder,12,"muted")
    w.text(self,28,369,"KNOWN TERRAIN / CHOOSE WHEN READY",12,"gold")
    for i,path in ipairs(report.routes) do
        local y=321-(i-1)*112
        w.button(self,28,y,834,36,path.label.." / "..path.distance.." km",function()
            self.perform("leave",{branch=path.id})
        end,{key=path.label,size=15,icon="trail"})
        w.text(self,38,y-9,path.facts,12,"muted",814)
        w.reading(self,38,y-48,path.help.icon,nil,{label=path.help.text,size=12,width=770})
    end
    local early=s.target==2
    w.button(self,28,76,405,36,early and "Rest beneath the oak" or "Prepare for the last stretch",function()
        if early then self.perform("rest") else self.open_page("camp") end
    end,{icon="rest",size=14})
    w.button(self,447,76,415,36,"Crew & work items",function() self.open_page("crew") end,{icon="crew",size=14,key="report_crew"})
    w.text(self,28,60,early and "Rest: 1 day + "..model.resources.daily_food(s).." food. Reading and crew changes take no time." or "Prepare before leaving. Reading and crew changes take no time.",12,"muted")
end
return M
