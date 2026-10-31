local icons=require "ui.icons"
local iconography=require "ui.iconography"
local M={}
M.colors={bg="152c29",panel="203b34",raised="2d4940",edge="3e594c",ink="efe7cf",muted="adbc9f",gold="e1bc70",sage="a9bd83",dark="142620",red="e6a184",sky="c2c9a2"}
function M.color(hex,alpha)
    hex=M.colors[hex] or hex
    return vmath.vector4(tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255,alpha or 1)
end
local function attach(self,n)
    gui.set_parent(n,self.root,false)
    return n
end
function M.begin(self)
    if self.buttons and self.buttons[self.focus or 1] then self.focus_key=self.buttons[self.focus or 1].key end
    if self.root then gui.delete_node(self.root) end
    self.root=gui.new_box_node(vmath.vector3(),vmath.vector3())
    self.buttons={};self.animated={};self.focus=1
end
function M.rect(self,x,y,w,h,color,alpha)
    local n=attach(self,gui.new_box_node(vmath.vector3(x+w/2,y+h/2,0),vmath.vector3(w,h,0)))
    gui.set_color(n,M.color(color or "panel",alpha))
    return n
end
function M.text(self,x,y,text,size,color,width)
    size=size or 16
    local scale=size/18
    local n=attach(self,gui.new_text_node(vmath.vector3(x,y,0),tostring(text)))
    gui.set_font(n,"body");gui.set_color(n,M.color(color or "ink"))
    gui.set_scale(n,vmath.vector3(scale,scale,1))
    gui.set_pivot(n,width and gui.PIVOT_NW or gui.PIVOT_W)
    if width then gui.set_size(n,vmath.vector3(width/scale,480/scale,0));gui.set_line_break(n,true) end
    return n
end
function M.panel(self,x,y,w,h)
    M.rect(self,x,y-3,w,h,"dark")
    M.rect(self,x,y,w,h,"edge")
    return M.rect(self,x+1,y+1,w-2,h-2,"panel")
end
function M.button(self,x,y,w,h,label,fn,options)
    options=options or {}
    local enabled=options.enabled~=false
    local base=options.primary and "sage" or (options.selected and "edge" or "raised")
    local node=M.rect(self,x,y,w,h,enabled and base or "panel")
    if options.icon then M.icon(self,x+10,y+(h-20)/2,options.icon,20,not enabled and "muted" or (options.primary and "dark" or nil)) end
    local text=M.text(self,x+w/2+(options.icon and 9 or 0),y+h/2,label,options.size or 15,enabled and (options.primary and "dark" or "ink") or "muted")
    gui.set_pivot(text,gui.PIVOT_CENTER)
    local focus_mark=M.rect(self,x+3,y+3,3,h-6,options.primary and "dark" or "gold")
    gui.set_enabled(focus_mark,false)
    self.buttons[#self.buttons+1]={node=node,label=text,focus_mark=focus_mark,fn=fn,key=options.key or label,enabled=enabled,base=base,primary=options.primary}
    return node
end
function M.bar(self,x,y,w,value,color,h)
    M.rect(self,x,y,w,h or 5,"dark")
    M.rect(self,x,y,w*math.max(0,math.min(100,value))/100,h or 5,color or "sage")
end
function M.icon(self,x,y,name,size,color)
    local ink=color or iconography.color(name)
    icons.draw(self,M.rect,x,y,name,size,ink,ink)
end
M.tint=iconography.color
function M.reading(self,x,y,id,value,options)
    options=options or {}
    local def=iconography.get(id)
    local size=options.icon_size or 24
    M.icon(self,x,y-size/2,id,size,options.color)
    return M.text(self,x+size+10,y,(options.label or def.label)..(value~=nil and " "..tostring(value) or ""),options.size or 15,options.ink or "ink",options.width)
end
function M.sprite(self,id,x,y,size,dim)
    local node=attach(self,gui.new_box_node(vmath.vector3(x,y,0),vmath.vector3(size,size,0)))
    gui.set_texture(node,"creatures");gui.play_flipbook(node,id)
    if dim then gui.set_color(node,vmath.vector4(0.55,0.6,0.55,1)) end
    return node
end
function M.finish(self)
    if self.focus_key then
        for i,b in ipairs(self.buttons) do if b.key==self.focus_key then self.focus=i; break end end
    end
    if not self.buttons[self.focus] or not self.buttons[self.focus].enabled then M.focus_next(self,1) end
    if self.keyboard then M.highlight(self,nil,nil,true) end
end
function M.highlight(self,x,y,keyboard)
    for i,b in ipairs(self.buttons) do
        local hovered=x and gui.pick_node(b.node,x,y)
        local active=b.enabled and (hovered or (keyboard and i==self.focus))
        gui.set_color(b.node,M.color(not b.enabled and "panel" or (active and (b.primary and "gold" or "edge") or b.base)))
        gui.set_enabled(b.focus_mark,b.enabled and keyboard and i==self.focus or false)
    end
end
function M.activate(self,x,y)
    for i=#self.buttons,1,-1 do
        local b=self.buttons[i]
        if b.enabled and gui.pick_node(b.node,x,y) then self.focus=i; b.fn(); return true end
    end
end
function M.focus_next(self,direction)
    if #self.buttons==0 then return end
    for _=1,#self.buttons do
        self.focus=((self.focus-1+direction)%#self.buttons)+1
        if self.buttons[self.focus].enabled then break end
    end
end
return M
