local w=require "ui.widgets"
local icons=require "ui.iconography"
local M={}
function M.draw(self)
    w.text(self,28,611,"FIELD GUIDE / SYMBOLS",12,"muted")
    w.text(self,28,575,"Know the marks. Read the road.",27,"ink")
    w.text(self,28,542,"Color helps recognition. Read the symbol, label and number together.",14,"muted")
    self.symbol_group=self.symbol_group or 1
    for n,group in ipairs(icons.groups) do
        local index=n
        w.button(self,28+(n-1)*280,482,263,38,group.label,function() self.symbol_group=index;self.redraw() end,{key="symbol_group"..n,selected=self.symbol_group==n,size=14})
    end
    for n,id in ipairs(icons.groups[self.symbol_group].ids) do
        local x=28+((n-1)%2)*425;local y=439-math.floor((n-1)/2)*59;local def=icons.get(id)
        w.icon(self,x+4,y-15,id,24)
        w.text(self,x+42,y+1,def.label,16,"ink")
        w.text(self,x+42,y-18,def.meaning,12,"muted",366)
    end
    w.button(self,28,56,263,34,"Back to the journal",function() self.open_page("journal") end,{key="symbols_back",size=13,icon="journal"})
end
return M
