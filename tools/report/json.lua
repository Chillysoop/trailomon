-- Deterministic JSON output for the command-line reporter; no engine dependency.
local M={}
local array_tag={}
function M.array(t) return setmetatable(t or {},array_tag) end
local function quote(s)
    return '"'..s:gsub('[%z\1-\31\\"]',function(c)
        if c=='"' or c=='\\' then return '\\'..c end
        return string.format('\\u%04x',c:byte())
    end)..'"'
end
function M.encode(v)
    local kind=type(v)
    if kind=='nil' then return 'null' end
    if kind=='boolean' then return v and 'true' or 'false' end
    if kind=='number' then
        assert(v==v and v~=math.huge and v~=-math.huge,'Non-finite report number')
        return string.format('%.17g',v)
    end
    if kind=='string' then return quote(v) end
    assert(kind=='table','Unsupported report value: '..kind)
    local keys={};local dense=true
    for k in pairs(v) do
        assert(type(k)=='string' or type(k)=='number','Unsupported report key')
        keys[#keys+1]=k
        if type(k)~='number' or k<1 or k%1~=0 then dense=false end
    end
    dense=dense and (#keys>0 or getmetatable(v)==array_tag)
    if dense then for i=1,#keys do if v[i]==nil then dense=false;break end end end
    local parts={}
    if dense then
        for i=1,#keys do parts[i]=M.encode(v[i]) end
        return '['..table.concat(parts,',')..']'
    end
    table.sort(keys,function(a,b) return type(a)..tostring(a)<type(b)..tostring(b) end)
    local seen={}
    for _,k in ipairs(keys) do
        local key=tostring(k);assert(not seen[key],'Colliding JSON keys');seen[key]=true
        parts[#parts+1]=quote(key)..':'..M.encode(v[k])
    end
    return '{'..table.concat(parts,',')..'}'
end
return M
