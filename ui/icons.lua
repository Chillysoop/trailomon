-- Original field-guide marks on a 12 x 12 grid. X = ink; + = accent.
-- Every use retains a text label. Horizontal runs reduce GUI node count.
local M={glyphs={
 focus="..XX....XX../.X........X./X..XX..XX..X/X.X......X.X/X.X..XX..X.X/X.X..XX..X.X/X.X......X.X/X..XX..XX..X/.X........X./..XX....XX../............/............",
 haul=".XX......XX./.XX......XX./..XXXXXXXX../..X......X../..X......X../..X......X../..XX....XX../...XXXXXX.../.....XX...../.....XX...../............/............",
 approach="........X.../........X.../..X.....X.../...X....X.../....X...X.../XXXXX...X.../....X...X.../...X....X.../..X.....X.../........X.../........X.../............",
 forage=".....X....../...X.X.X..../....XXX...../.....X....../.X.......X../.XXXXXXXXX../..X.X.X.X.../..X.X.X.X.../...XXXXX..../............/............/............",
 food=".....X....../..X..X..X.../..XX.X.XX.../...XXXXX..../.....X....../.XX..X..XX../..XX.X.XX.../...XXXXX..../.....X....../.....X....../....XXX...../............",
 coins="...XXXXXX.../..XX....XX../.XX......XX./.X...++...X./.X..+..+..X./.X..+..+..X./.X...++...X./.XX......XX./..XX....XX../...XXXXXX.../............/............",
 wagon="..XXXXXX..../.XX....XX.../.X......X.../.X......X.../.XXXXXXXX.../.X......XXX./.XXXXXXXX.../..X....X..../.XXX..XXX.../..X....X..../............/............",
 cargo="......XXX.../...XX.XX..../...XXXX...../.....X....../.....X....../..XXXXXXX.../..X.....X.../..X..+..X.../..X.....X.../..XXXXXXX.../............/............",
 condition="............/..XX...XX.../.XXXX.XXXX../.XXXXXXXXX../.XXXXXXXXX../..XXXXXXX.../...XXXXX..../....XXX...../.....X....../............/............/............",
 stamina="..XX...XX.../.XXX...XXX../.XXX...XXX../.XXX...XXX../..XX...XX.../...X...X..../...XXXXX..../...XXXXX..../....XXX...../............/............/............",
 repairs=".....XXXX.../...XXXXXX.../..XXXXXXX.../..XX..XXX.../....XX....../...XX......./..XX......../.XX........./XX........../............/............/............",
 medicine="....XXXX..../....XXXX..../.....XX...../...XXXXXX.../...X....X.../...X.++.X.../...X++++X.../...X.++.X.../...X....X.../...XXXXXX.../............/............",
 time=".....X....../..X.....X.../....XXX...../...X...X..../X..X.+.X..X./...X.++X..../....XXX...../..X.....X.../.....X....../............/............/............",
 capacity="....XXXX..../...X....X.../...XXXXXX.../..XXXXXXXX../..X......X../..X.XXXX.X../..X.X..X.X../..X.XXXX.X../..X......X../..XXXXXXXX../............/............",
 scout="............/....XXX...../..XX...XX.../.X..XXX..X../X...X+X...X./.X..XXX..X../..XX...XX.../....XXX...../............/............/............/............",
 water="............/.XX...XX..../X..X.X..X.X./....X....X../............/.XX...XX..../X..X.X..X.X./....X....X../............/............/............/............",
 guard=".XXXXXXXXX../.X.......X../.X...+...X../.X..+++..X../.X...+...X../..X.....X.../..X.....X.../...X...X..../....X.X...../.....X....../............/............",
 journal="............/.XXXX.XXXX../.X..XXX..X../.X...X...X../.X.+.X.+.X../.X...X...X../.X.+.X.+.X../.X...X...X../.XXXX.XXXX../.....X....../............/............",
 map=".XXX......../.X..XXX.XX../.X..X..X.X../.X..X..X.X../.X..X+.X.X../.X..X..X.X../.X..X..X.X../.XX.X..X.X../...XXX..XX../......XXX.../............/............",
 crew="...XX.XX..../XX.XX.XX.XX./XX.......XX./.....X....../...XXXXX..../..XXXXXXX.../..XXXXXXX.../...XX.XX..../............/............/............/............",
 trail="......XX..../.....XX...../....XX....../...XX......./...XX......./....XX....../.....XX...../.....XX...../....XX....../...XX......./............/............",
 settings="....XXX...../.XX.XXX.XX../.XXXXXXXXX../..XX...XX.../XXXX...XXXX./XXXX...XXXX./..XX...XX.../.XXXXXXXXX../.XX.XXX.XX../....XXX...../............/............",
 rest=".....X....../....XXX...../...XXXXX..../..XXX.XXX.../..XX...XX.../.XXX...XXX../.XX.....XX../XXXXXXXXXXX./............/............/............/............",
 pressure="......XX..../.....XXX..../....XXXX..../...XXXX...../..XXXXX...../.....XX...../....XX....../...XX......./..XX......../............/............/............",
 assist=".....X....../.....X....../....XXX...../...XXXXX..../XXXXXXXXXXX./...XXXXX..../....XXX...../.....X....../.....X....../............/............/............",
 warm=".....XX...../....XX....../...XX......./...XX...X.../....XX.XX.../..X.XXXXX.../..XXXXXXX.../...XXXXX..../....XXX...../............/............/............",
 flag="..X........./..XXXXXXX.../..X++++XX.../..X+++XX..../..XXXXXX..../..X........./..X........./..X........./.XXX......../............/............/............",
 dig="....XXXXX.../.....XXX..../......X...../......X...../......X...../....XXXXX.../....XXXXX.../.....XXX..../......X...../............/............/............",
}}
function M.draw(self,rect,x,y,name,size,ink,accent)
    local glyph=assert(M.glyphs[name],"Unknown interface icon: "..tostring(name))
    -- Whole-pixel marks at 12/24/36 px, centered in the requested space.
    local unit=math.max(1,math.floor((size or 24)/12+0.5))
    x=math.floor(x+((size or 24)-unit*12)/2+0.5)
    y=math.floor(y+((size or 24)-unit*12)/2+0.5)
    local row=0
    for line in glyph:gmatch("[^/]+") do
        row=row+1
        local col=1
        while col<=#line do
            local mark=line:sub(col,col)
            if mark=="." then col=col+1 else
                local finish=col
                while line:sub(finish+1,finish+1)==mark do finish=finish+1 end
                rect(self,x+(col-1)*unit,y+(12-row)*unit,(finish-col+1)*unit,unit,mark=="+" and (accent or "gold") or (ink or "muted"))
                col=finish+1
            end
        end
    end
end
return M
