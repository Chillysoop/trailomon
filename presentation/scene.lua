-- The landscape is native GUI geometry, so it can move independently of the
-- creature atlas. No simulation RNG is consumed by presentation.
local w=require "ui.widgets"
local M={}
local function pixel_tree(self,x,y,size,color)
    w.rect(self,x-3,y,6,size*0.6,"6d6846")
    for i=1,4 do
        local width=size*(1.12-i*0.17)
        w.rect(self,x-width/2,y+size*0.28+i*size*0.13,width,size*0.26,color)
    end
end
local function circle(self,x,y,r,color)
    local n=gui.new_pie_node(vmath.vector3(x,y,0),vmath.vector3(r*2,r*2,0))
    gui.set_parent(n,self.root,false);gui.set_color(n,w.color(color));gui.set_perimeter_vertices(n,12)
    return n
end
function M.draw(self,x,y,width,height,s)
    local rainy=s.weather=="rain"
    w.rect(self,x,y,width,height,rainy and "8baba4" or "bec9a0")
    circle(self,x+width*0.76,y+height*0.76,26,rainy and "c6c9ad" or "efe1ad")
    for layer=1,3 do
        local colors={"98ad8c","7f9d7d","648a6d"}
        for j=0,math.floor(width/16) do
            local hill=height*(0.24+0.075*layer)+math.sin(j*0.105+layer*1.8)*height*0.12+math.sin(j*0.24+layer)*7
            w.rect(self,x+j*16,y,math.min(16,width-j*16),hill,colors[layer])
        end
    end
    local floor=y+height*0.22
    w.rect(self,x,y,width,height*0.23,"507454")
    w.rect(self,x,floor-8,width,21,"aa986b")
    w.rect(self,x,floor-11,width,4,"c2af7b")
    for j=1,9 do
        local tx=x+23+j*(width-45)/10
        pixel_tree(self,tx,floor+26,35+(j%3)*12,j%2==0 and "3e684e" or "426f54")
    end
    -- Wagon, canvas, traveler, and wheels: deliberately modest prototype props.
    local wx=x+width*0.52
    local wy=floor+11
    w.rect(self,wx-45,wy+7,92,39,"795a40")
    w.rect(self,wx-47,wy+9,96,5,"b48a56")
    w.rect(self,wx-41,wy+36,78,31,"e2d3ab")
    w.rect(self,wx-33,wy+65,62,9,"e2d3ab")
    w.rect(self,wx-28,wy+72,48,5,"e2d3ab")
    w.rect(self,wx-41,wy+36,8,25,"bfae87")
    w.rect(self,wx+31,wy+36,6,31,"a59069")
    if s.wagon_type=="standard" then w.rect(self,wx-25,wy+36,45,25,"c5b58e") end
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
    local battle=s.battle and s.battle.rules=="automatic-v1" and (s.mode=="combat" or s.mode=="combat_result") and s.battle
    local positions={}
    if battle then for n,i in ipairs(battle.team) do positions[i]=n end end
    for i,c in ipairs(s.crew) do
        local is_haul=i==s.hauler
        local px=is_haul and wx+125 or wx-80-(i-1)*56
        local py=wy+21+(c.species=="bellmoth" and 35 or 0)
        local size=is_haul and 104 or 76
        if battle then
            px=positions[i]==1 and x+width*0.72 or x+width*0.29
            py=wy+21;size=90
        end
        if not battle or positions[i] then
        local node=w.sprite(self,c.species,px,py,size,c.condition<25)
        self.animated[#self.animated+1]={node=node,x=px,y=py,phase=i*1.7,fly=c.species=="bellmoth",combat=battle~=nil}
        if battle then
            w.rect(self,px-65,y+3,130,20,"dark")
            w.text(self,px-59,y+13,positions[i]==1 and "APPROACH" or "WAGON",11,"ink")
            if s.mode=="combat" and battle.intent.target==i then w.rect(self,px-44,py-38,88,3,"gold") end
        end
        end
    end
    if battle and s.mode=="combat" then
        w.sprite(self,battle.kind=="scavengers" and "loamling" or "slatewhorl",x+width*0.91,wy+23,88)
        local tx=battle.intent.target=="cargo" and wx or x+width*0.72
        w.rect(self,tx,wy+84,x+width*0.91-tx,2,"gold")
        w.rect(self,tx,wy+81,4,8,"gold")
        if battle.intent.target=="cargo" then w.rect(self,wx-43,wy+4,86,3,"gold") end
    end
    for j=1,24 do
        local px=x+12+((j*107)%math.floor(width-25))
        local py=y+8+(j%4)*9
        w.rect(self,px,py,3,6,"719663")
        if j%4==0 then w.rect(self,px-1,py+5,5,4,"e1bc70") end
    end
    if rainy then
        for j=1,28 do
            local rx=x+7+((j*71)%math.floor(width-15))
            local ry=y+25+((j*39)%math.floor(height-40))
            local n=w.rect(self,rx,ry,2,9,"d3e0cb",0.65)
            self.animated[#self.animated+1]={node=n,x=rx+1,y=ry+4.5,phase=j,rain=true}
        end
    elseif s.weather=="cold" then
        for j=1,16 do w.rect(self,x+((j*113)%math.floor(width-8)),y+22+((j*47)%math.floor(height-30)),3,3,"efe7cf",0.8) end
    end
end
function M.update(self,time,moving,enabled)
    if not enabled then return end
    for _,a in ipairs(self.animated) do
        local offset=a.rain and ((time*45+a.phase*7)%20)-10 or math.sin(time*(moving and 5 or 1.4)+a.phase)*(a.fly and 4 or (moving and 2 or 0.7))
        local lunge=a.combat and self.exchange_started and math.max(0,1-(time-self.exchange_started)/0.6)*6 or 0
        gui.set_position(a.node,vmath.vector3(a.x+lunge,a.y+offset,0))
    end
end
return M
