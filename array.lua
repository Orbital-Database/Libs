-- array.lua
-- Custom utility library for Lua 5.3
-- Author: You (and ChatGPT 😎)

local array = {}

-------------------------------------------------
-- 🧱 Basic Functions
-------------------------------------------------

function array.new(...)
    return {...}
end

function array.get(t, index)
    return t[index]
end

function array.set(t, index, value)
    t[index] = value
end

function array.length(t)
    return #t
end

-------------------------------------------------
-- ➕ Add / ➖ Remove
-------------------------------------------------

-- Add at bottom
function array.push(t, value)
    table.insert(t, value)
end

-- Add at top (cool name: ascend)
function array.ascend(t, value)
    table.insert(t, 1, value)
end

-- Remove last element
function array.pop(t)
    return table.remove(t)
end

-- Remove first element
function array.shiftTop(t)
    return table.remove(t, 1)
end

-- Remove by value (first match)
function array.removeValue(t, value)
    local i = array.find(t, value)
    if i then
        table.remove(t, i)
        return true
    end
    return false
end

-------------------------------------------------
-- 🔎 Searching / Counting
-------------------------------------------------

function array.find(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return nil
end

function array.count(t, value)
    local c = 0
    for _, v in ipairs(t) do
        if v == value then
            c = c + 1
        end
    end
    return c
end

-------------------------------------------------
-- 🔀 Sorting / Moving
-------------------------------------------------

-- Sort array alphabetically or numerically
-- mode: "AZ", "ZA", "09", "90"
function array.sort(t, mode)
    local sorted = {table.unpack(t)}
    if mode == "AZ" then
        table.sort(sorted, function(a, b)
            return tostring(a) < tostring(b)
        end)
    elseif mode == "ZA" then
        table.sort(sorted, function(a, b)
            return tostring(a) > tostring(b)
        end)
    elseif mode == "09" then
        table.sort(sorted, function(a, b)
            return tonumber(a) < tonumber(b)
        end)
    elseif mode == "90" then
        table.sort(sorted, function(a, b)
            return tonumber(a) > tonumber(b)
        end)
    else
        table.sort(sorted)
    end
    return sorted
end

-- Move element to a new index
function array.shift(t, old_index, new_index)
    if old_index < 1 or old_index > #t or new_index < 1 or new_index > #t then
        return false, "index out of range"
    end
    local val = table.remove(t, old_index)
    table.insert(t, new_index, val)
    return true
end

-------------------------------------------------
-- 🧠 Higher-Order Functions
-------------------------------------------------

function array.map(t, fn)
    local result = {}
    for i, v in ipairs(t) do
        result[i] = fn(v, i)
    end
    return result
end

function array.filter(t, fn)
    local result = {}
    for i, v in ipairs(t) do
        if fn(v, i) then
            table.insert(result, v)
        end
    end
    return result
end

function array.reduce(t, fn, init)
    local acc = init
    for i, v in ipairs(t) do
        if acc == nil then
            acc = v
        else
            acc = fn(acc, v, i)
        end
    end
    return acc
end

-------------------------------------------------
-- 🧾 Debug / Display
-------------------------------------------------

function array.print(t)
    io.write("[ ")
    for i, v in ipairs(t) do
        io.write(tostring(v))
        if i < #t then io.write(", ") end
    end
    print(" ]")
end

-------------------------------------------------
-- ✅ Return Library
-------------------------------------------------
return array
