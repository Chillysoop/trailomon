local M = {}

function M.copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = M.copy(v) end
    return result
end

function M.clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

function M.finite(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

function M.round(n) return math.floor(n + 0.5) end

return M
