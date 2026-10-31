-- Authored scenery on a three-pixel grid. The road changes with place, never RNG.
local route=require "content.route"
local M={}

function M.place(s)
    if s.mode=="preparation" then return "depot" end
    if s.mode=="landmark" or s.mode=="result" and (s.outcome=="delivered" or s.outcome=="late") then
        return route[s.target].id
    end
    local progress=s.progress/math.max(1,s.distance)
    if s.target==2 and progress<0.18 then return "depot" end
    if progress>=0.82 then return route[s.target].id end
    return s.terrain
end

local palettes={
    low={sky="c4cba5",far="a3b191",middle="819e7b",near="63876a",ground="57784e",road="b4a16c"},
    wood={sky="b5c4a0",far="96ac8c",middle="71947a",near="4f7561",ground="4c6c4e",road="9c9168"},
    wet={sky="bdcdc0",far="9bb4a5",middle="7c9b8c",near="5d8778",ground="647c60",road="a89d78"},
    high={sky="cbd0bc",far="a7b2ad",middle="829896",near="647e79",ground="6a7960",road="a39c7b"},
    reach={sky="aebfbc",far="8a9fa2",middle="718b8c",near="536e6c",ground="5a725e",road="a39c7b"},
}
function M.draw(self,w,x,y,width,height,s)
    local place=M.place(s)
    local high=s.target>=5 or place=="ridge" or place=="gorge"
    local p=palettes[place=="reach" and "reach" or (high and "high" or ((place=="river" or place=="marsh") and "wet" or ((place=="woodland" or place=="outpost") and "wood" or "low")))]
    local floor=math.floor(height*0.22/3)*3
    -- Every primitive is clipped to this viewport, including the shorter landmark view.
    local function r(px,py,pw,ph,c)
        px=math.floor(px/3)*3;py=math.floor(py/3)*3
        local right=math.min(width,px+math.ceil(pw/3)*3)
        local top=math.min(height,py+math.ceil(ph/3)*3)
        px=math.max(0,px);py=math.max(0,py)
        if right>px and top>py then w.rect(self,x+px,y+py,right-px,top-py,c) end
    end
    local function hill(points,color)
        for i=1,#points-1 do
            local a,b=points[i],points[i+1]
            local start,span,last
            local function flush()
                if start then r(start,floor,span,last,color) end
            end
            for px=a[1]*width,b[1]*width-1,12 do
                local t=(px/width-a[1])/(b[1]-a[1])
                local h=math.ceil((a[2]+(b[2]-a[2])*t)*height/3)*3
                -- Adjacent flat steps share one node; identical pixels, fewer GUI nodes.
                if start and h==last then span=span+12
                else flush();start=px;span=12;last=h end
            end
            flush()
        end
    end
    local function tree(tx,base,size,c)
        r(tx-3,base,6,size*.65,"766c4c")
        r(tx-size*.3,base+size*.48,size*.6,size*.36,c)
        r(tx-size*.45,base+size*.38,size*.9,size*.23,c)
        r(tx-size*.2,base+size*.78,size*.4,size*.16,c)
    end
    local function house(tx,base,scale,lit)
        r(tx,base,66*scale,36*scale,"c1ae82")
        r(tx-6*scale,base+33*scale,78*scale,6*scale,"695444")
        for i=0,4 do r(tx+i*6*scale,base+(39+i*3)*scale,(66-i*12)*scale,3*scale,"8e7053") end
        r(tx+27*scale,base,15*scale,27*scale,"4e5c4a")
        r(tx+9*scale,base+15*scale,9*scale,12*scale,lit and "e1bc70" or "60745e")
        r(tx+48*scale,base+15*scale,9*scale,12*scale,lit and "e1bc70" or "60745e")
    end
    local function cairn(tx,base,scale)
        for i=0,3 do r(tx+i*3*scale+(i%2)*3,base+i*9*scale,(30-i*6)*scale,9*scale,i%2==0 and "9f9c7e" or "858d78") end
    end
    r(0,0,width,height,s.weather=="rain" and "97aea7" or p.sky)
    -- Flat, stepped cloud banks keep the open sky quiet.
    r(width*.07,height*.8,width*.23,6,"d7d9bd")
    r(width*.1,height*.8+6,width*.11,6,"d7d9bd")
    if high then
        hill({{0,.22},{.14,.47},{.24,.3},{.38,.62},{.5,.42},{.63,.54},{.76,.26},{.9,.43},{1,.31}},p.far)
        hill({{0,.16},{.2,.34},{.35,.18},{.53,.38},{.66,.22},{.85,.31},{1,.12}},p.middle)
        if place=="gorge" then
            hill({{0,.67},{.13,.58},{.28,.18},{.5,.08},{.75,.15},{.88,.6},{1,.7}},p.near)
            r(width*.48,floor+12,width*.04,18,"8da9a0")
        else
            hill({{0,.12},{.18,.18},{.4,.08},{.62,.2},{.82,.11},{1,.16}},p.near)
        end
    else
        hill({{0,.29},{.16,.42},{.32,.25},{.54,.34},{.76,.22},{1,.38}},p.far)
        hill({{0,.17},{.23,.28},{.5,.13},{.74,.25},{1,.16}},p.middle)
        hill({{0,.1},{.2,.13},{.42,.05},{.7,.16},{1,.07}},p.near)
    end
    r(0,0,width,floor+9,p.ground)
    local base=floor+15
    if place=="depot" then
        house(45,base,1.3,false)
        -- Nursery rows and graft ties, rather than a generic village skyline.
        for i=1,5 do
            local tx=width*.62+i*43
            tree(tx,base,36,"5e7951");r(tx-6,base+12,12,3,"e1bc70")
            r(tx-12,base-6,27,3,"8b885e")
        end
        r(12,base-3,270,6,"b4a779")
        for i=0,6 do r(18+i*42,base-12,6,24,"b4a779") end
    elseif place=="split" then
        local tx=width*.23
        r(tx-18,base,15,75,"6a5841");r(tx+12,base,15,84,"6a5841")
        r(tx-33,base+54,18,36,"6a5841");r(tx+24,base+63,18,30,"6a5841")
        r(tx-75,base+87,66,27,"466d4d");r(tx-63,base+108,48,12,"466d4d")
        r(tx+9,base+96,75,21,"547a51");r(tx+21,base+114,45,9,"547a51")
        r(tx+18,base+15,33,24,"cabd92");r(tx+12,base+39,45,6,"765f43")
        for i=1,3 do r(tx+24,base+15+i*6,15,3,"877b57") end
        for i=1,4 do tree(width*.7+i*45,base,33+i*6,"567752") end
    elseif place=="outpost" then
        house(width*.13,base,1.65,false)
        -- Long provision porch, drying shelves, rim and a small service bell.
        local tx=width*.13
        r(tx+90,base+48,87,9,"695444");r(tx+165,base,6,51,"947a51")
        r(tx+108,base+3,45,18,"a18b5c");r(tx+102,base+24,54,6,"c1ae82")
        r(tx+135,base+39,9,9,"dfb969");r(tx+138,base+48,3,6,"695444")
        r(tx-15,base+3,18,24,"6a5841");r(tx-9,base+9,6,12,"c1ae82")
        for _,tx2 in ipairs({width*.62,width*.8,width*.92}) do tree(tx2,base,54,"4f7057") end
    elseif place=="river" or place=="marsh" then
        r(0,floor+9,width,height*.27,"7eaaa1")
        for i=1,10 do r(i*width/11,floor+15+(i%3)*12,36+(i%2)*21,3,"b5c9b5") end
        for i=1,7 do
            local tx=i*width/8
            r(tx,base,3,18+(i%3)*6,"688168");r(tx+6,base,3,24,"688168")
        end
        if place=="river" then
            local tx=width*.71
            r(tx-24,base+15,153,6,"8b7652");r(tx-12,base+3,6,36,"8b7652")
            r(tx+87,base+6,6,39,"8b7652");r(tx+3,base+24,72,9,"b09b6b")
            r(tx+12,base+33,6,18,"75694f");r(tx+66,base+33,6,18,"75694f")
            r(tx-24,base+51,153,3,"ccc5a0")
            r(78,base,9,63,"7b7152")
            for i=1,5 do r(78,base+i*9,6,3,"d9caa2") end
            r(42,base+6,6,24,"a2a786") -- Old, stranded water mark.
        end
    elseif place=="gate" then
        house(195,base,.75,false)
        cairn(129,base,1.35);cairn(273,base,1.65)
        -- The only shelter is low under the high-country horizon.
        r(195,base,51,12,"879078")
    elseif place=="reach" then
        -- Only a few occupied windows, with empty orchard terraces beyond.
        house(width*.73,base,.75,true);house(width*.87,base+9,.6,true)
        for i=1,3 do r(42,base+i*12,180-i*24,3,"93977b") end
        for i=1,4 do r(69+i*30,base+15,3,18,"8d8c6c") end
    elseif place=="woodland" then
        for i=0,8 do tree(24+i*102,base,48+(i%3)*12,"466f54") end
    elseif not high then
        for _,tx in ipairs({width*.08,width*.2,width*.85}) do tree(tx,base,42,"5d8056") end
    end
    -- Tended wheel tracks give way to broken ruts, then isolated stone/grass marks.
    if not high and s.target<=3 then
        r(0,floor-9,width,18,p.road);r(0,floor-12,width,3,"c5b27c")
        r(0,floor+3,width,3,"c5b27c")
    else
        r(0,floor-9,width,12,p.road)
        for i=0,8 do r(i*96+(i%2)*9,floor+3,high and 36 or 60,3,p.road) end
        if high then for _,tx in ipairs({39,114,318,744}) do r(tx,floor-6,15,9,p.ground) end end
    end
    return x,y+floor,place
end
return M
