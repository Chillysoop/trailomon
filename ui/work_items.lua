local w=require "ui.widgets"
local model=require "simulation.expedition"
local gear=model.equipment
local M={}
function M.draw(self)
    local s=self.snapshot.run
    local selected=math.min(self.work_member or 1,math.max(1,#s.crew));self.work_member=selected
    local c=s.crew[selected];local can=gear.can_equip(s)
    w.text(self,28,611,"WORK ITEMS / ONE SLOT PER COMPANION",12,"muted")
    w.text(self,28,575,"Pack for the work ahead.",27,"ink")
    w.button(self,657,558,205,34,"Back to crew",function() self.open_page("crew") end,{key="items_back",size=13,icon="crew"})
    w.reading(self,28,536,"coins",s.coins,{size=13})
    w.reading(self,198,536,"capacity",model.resources.weight(s).." / "..model.resources.capacity(s),{size=13})
    w.text(self,410,536,can and "Repack for each expedition. No time cost to swap." or "Locked until stopped outside an encounter.",12,can and "muted" or "gold")
    for i,member in ipairs(s.crew) do
        local idx=i
        w.button(self,28+(i-1)*280,480,263,35,"For "..member.name,function() self.work_member=idx;self.redraw() end,{key="item_member"..i,selected=selected==i,size=14})
    end
    if not c then w.text(self,28,496,"Choose a crew at the depot before assigning items.",13,"muted") end
    for n,id in ipairs(gear.order) do
        local item=gear.defs[id];local y=337-(n-1)*132
        local owned=(s.work_items or {})[id];local wearer=gear.wearer(s,id)
        local equipped=c and c.work_item==id
        local buy=not owned and gear.shop(s) and s.coins>=item.price and model.resources.weight(s)+item.weight<=model.resources.capacity(s)
        w.panel(self,28,y,834,120)
        w.text(self,48,y+98,item.name,19,"ink")
        w.text(self,298,y+98,item.price.." coins / "..item.weight.." load / "..(wearer and "on "..wearer.name or (owned and "packed" or "not packed")),12,"gold")
        w.icon(self,48,y+58,item.icon,12,"sage")
        w.text(self,68,y+65,item.travel,12,"muted")
        w.text(self,48,y+43,item.battle,12,"muted",592)
        local action=not owned and "Buy: "..item.price.." coins" or (equipped and "Unequip" or (wearer and "Move to "..(c and c.name or "crew") or "Equip"))
        w.button(self,656,y+63,186,32,action,function()
            if not owned then self.perform("buy_work_item",{item=id})
            else self.perform("equip_work_item",{member=selected,item=not equipped and id or nil}) end
        end,{key="item_"..id,enabled=owned and can and c~=nil or buy,size=12,selected=equipped})
        if owned and s.mode=="preparation" then
            w.button(self,656,y+19,186,29,"Return: +"..item.price.." coins",function() self.perform("sell_work_item",{item=id}) end,{key="return_"..id,size=12})
        else
            local reason=owned and (can and "Swaps keep the same load." or "No encounter swaps.") or (not gear.shop(s) and "Buy at Fernwake / Mossbell." or (s.coins<item.price and "Not enough coins." or (not buy and "No carrying room." or "Buy, then equip above.")))
            w.text(self,656,y+32,reason,10,"muted",185)
        end
    end
    w.text(self,28,51,"One of each item. Packed items use load even when unequipped. Returns only before departure.",11,"muted")
end
return M
