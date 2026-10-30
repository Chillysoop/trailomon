-- Park-Miller uses products below 2^53: identical with Lua 5.1 doubles and LuaJIT.
-- The mutable value lives in the saved expedition, never in this module.
local M = {}
local modulus = 2147483647
function M.seed(value)
    value = tonumber(value) or 1
    if value ~= value or value == math.huge or value == -math.huge then value = 1 end
    return math.floor(math.abs(value)) % (modulus - 1) + 1
end
function M.next(streams, name)
    streams[name] = (streams[name] * 48271) % modulus
    return streams[name] / modulus
end
function M.int(streams, name, low, high)
    return low + math.floor(M.next(streams, name) * (high - low + 1))
end
return M
