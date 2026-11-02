local w=require "ui.widgets"
local M={}
local function circle(self,x,y,r,color)
    local n=gui.new_pie_node(vmath.vector3(x,y,0),vmath.vector3(r*2,r*2,0))
    gui.set_parent(n,self.root,false);gui.set_color(n,w.color(color));gui.set_perimeter_vertices(n,12)
    return n
end
function M.draw(self,wx,wy,kind)
    w.rect(self,wx-45,wy+7,92,39,"795a40")
    w.rect(self,wx-47,wy+9,96,5,"b48a56")
    w.rect(self,wx-41,wy+36,78,31,"e2d3ab")
    w.rect(self,wx-33,wy+65,62,9,"e2d3ab")
    w.rect(self,wx-28,wy+72,48,5,"e2d3ab")
    w.rect(self,wx-41,wy+36,8,25,"bfae87")
    w.rect(self,wx+31,wy+36,6,31,"a59069")
    if kind=="standard" then w.rect(self,wx-25,wy+36,45,25,"c5b58e") end
    w.rect(self,wx+44,wy+14,54,4,"775f40")
    for _,offset in ipairs({-28,28}) do
        circle(self,wx+offset,wy+4,14,"3e3930")
        circle(self,wx+offset,wy+4,9,"b39462")
        w.rect(self,wx+offset-1,wy-5,3,18,"625038")
        w.rect(self,wx+offset-9,wy+3,18,3,"625038")
    end
    w.rect(self,wx+33,wy+44,10,17,"496957")
    w.rect(self,wx+34,wy+61,8,8,"c89c6b")
    w.rect(self,wx+30,wy+67,18,4,"806a43")
end
return M
