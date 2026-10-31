local w=require "ui.widgets"
local guide=require "simulation.field_guide"
local iconography=require "ui.iconography"
local M={}
function M.draw(self)
    w.text(self,28,611,"FIELD GUIDE / SIX COMPANION SPECIES",12,"muted")
    w.text(self,28,575,"Life along the road.",28,"ink")
    local rows=guide.rows(self.snapshot)
    for i,row in ipairs(rows) do
        local y=510-(i-1)*69
        w.sprite(self,row.id,61,y-7,58,not row.known)
        w.reading(self,103,y,iconography.role(row.id),nil,{label=row.name,size=17,icon_size=16})
        local states={{"Known",row.known},{"Seen wild",row.seen},{"Traveled",row.traveled}}
        for j,state in ipairs(states) do w.text(self,370+(j-1)*156,y,state[1]..": "..(state[2] and "Yes" or "--"),12,state[2] and "ink" or "muted") end
        w.text(self,103,y-24,row.note,12,"muted",744)
        if i<6 then w.rect(self,28,y-42,834,1,"edge") end
    end
    w.button(self,28,68,240,32,"Back to Journal",function() self.open_page("journal") end,{key="field_back",icon="journal",size=12})
    w.text(self,291,86,"New observations return home with the expedition.",12,"muted")
end
return M
