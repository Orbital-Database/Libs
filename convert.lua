-- convert.lua
-- Multi-type conversion utility for Lua 5.3
-- Author: You (and ChatGPT 😎)

local convert = {}

-------------------------------------------------
-- 🔢 Basic numeric conversions
-------------------------------------------------

-- Integer → Float
function convert.intToFloat(n)
    return tonumber(n) + 0.0
end

-- Float → Integer (truncates)
function convert.floatToInt(f)
    return math.floor(tonumber(f))
end

-- Number → String
function convert.toString(v)
    return tostring(v)
end

-- String → Number (auto detect)
function convert.toNumber(s)
    return tonumber(s)
end

-- Boolean → Number (true=1, false=0)
function convert.boolToNum(b)
    return b and 1 or 0
end

-- Number → Boolean (0=false, else=true)
function convert.numToBool(n)
    return n ~= 0
end

-------------------------------------------------
-- 💻 Binary / Hex conversions
-------------------------------------------------

-- Number → Binary string
function convert.numToBinary(n)
    local bits = {}
    n = math.floor(tonumber(n))
    repeat
        table.insert(bits, 1, n % 2)
        n = math.floor(n / 2)
    until n == 0
    return table.concat(bits)
end

-- Binary string → Number
function convert.binaryToNum(bin)
    return tonumber(bin, 2)
end

-- Number → Hex string
function convert.numToHex(n)
    return string.format("%X", math.floor(tonumber(n)))
end

-- Hex string → Number
function convert.hexToNum(hex)
    return tonumber(hex, 16)
end

-- Float → Hex (IEEE-754 32-bit)
function convert.floatToHex(f)
    local sign = 0
    if f < 0 then
        sign = 1
        f = -f
    end
    local mant, exp = math.frexp(f)
    if f == 0 then
        mant, exp = 0, 0
    else
        mant = (mant * 2 - 1) * (2 ^ 23)
        exp = exp + 126
    end
    local bits = sign * 0x80000000 + exp * 0x800000 + mant
    return string.format("%08X", bits)
end

-- Hex → Float (IEEE-754 32-bit)
function convert.hexToFloat(hex)
    local num = tonumber(hex, 16)
    if not num then return 0 end
    local sign = ((num >> 31) == 1) and -1 or 1
    local exp = (num >> 23) & 0xFF
    local mant = num & 0x7FFFFF
    if exp == 0 then
        return sign * (mant / (2 ^ 23)) * (2 ^ (-126))
    end
    return sign * (1 + mant / (2 ^ 23)) * (2 ^ (exp - 127))
end

-------------------------------------------------
-- 🧩 String encoding helpers
-------------------------------------------------

-- String → Hex
function convert.stringToHex(str)
    return (str:gsub(".", function(c)
        return string.format("%02X", string.byte(c))
    end))
end

-- Hex → String
function convert.hexToString(hex)
    return (hex:gsub("..", function(cc)
        return string.char(tonumber(cc, 16))
    end))
end

-- String → Binary
function convert.stringToBinary(str)
    local result = {}
    for i = 1, #str do
        table.insert(result, string.format("%08b", string.byte(str, i)))
    end
    return table.concat(result, " ")
end

-- Binary → String
function convert.binaryToString(bin)
    local result = {}
    for byte in bin:gmatch("%d%d%d%d%d%d%d%d") do
        table.insert(result, string.char(tonumber(byte, 2)))
    end
    return table.concat(result)
end

-------------------------------------------------
-- 🔄 Table conversions
-------------------------------------------------

-- Table → String (simple)
function convert.tableToString(t)
    local parts = {}
    for k, v in pairs(t) do
        table.insert(parts, tostring(k) .. "=" .. tostring(v))
    end
    return "{ " .. table.concat(parts, ", ") .. " }"
end

-- String → Table (key=value pairs)
function convert.stringToTable(str)
    local t = {}
    for k, v in str:gmatch("(%w+)=([^,}]+)") do
        t[k] = v
    end
    return t
end

-------------------------------------------------
-- ✅ Return library
-------------------------------------------------
return convert
