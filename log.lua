--=========================================================
--  LOG Library - Lightweight Logging System
--=========================================================
local log = {}

------------------------------------------------------------
-- Default settings
------------------------------------------------------------
log.path = "log.txt"   -- default log file
log.enabled = true      -- toggle global logging
log.buffer = {}         -- in-memory log list
log.maxBuffer = 1000    -- auto-trim oldest logs

------------------------------------------------------------
-- Internal helpers
------------------------------------------------------------
local function timestamp()
    return os.date("[%Y-%m-%d %H:%M:%S]")
end

local function writeToFile(msg)
    local f = io.open(log.path, "a")
    if not f then return false, "Cannot open log file" end
    f:write(msg .. "\n")
    f:close()
    return true
end

------------------------------------------------------------
-- API: set log file path
------------------------------------------------------------
function log.setPath(path)
    if type(path) ~= "string" then
        return false, "Invalid path"
    end
    log.path = path
    return true
end

------------------------------------------------------------
-- API: add new log entry
-- log.log("message", true/false)
------------------------------------------------------------
function log.log(message, saveToFile)
    if not log.enabled then return end
    local msg = string.format("%s %s", timestamp(), tostring(message))
    table.insert(log.buffer, msg)

    -- Keep buffer from growing too large
    if #log.buffer > log.maxBuffer then
        table.remove(log.buffer, 1)
    end

    if saveToFile then
        writeToFile(msg)
    end
end

------------------------------------------------------------
-- API: get all logs as table or string
------------------------------------------------------------
function log.get(asTable)
    if asTable then
        return log.buffer
    else
        return table.concat(log.buffer, "\n")
    end
end

------------------------------------------------------------
-- API: clear all logs
------------------------------------------------------------
function log.remove(clearFile)
    log.buffer = {}
    if clearFile then
        local f = io.open(log.path, "w")
        if f then f:close() end
    end
end

------------------------------------------------------------
-- API: quick shortcuts for categorized logs
------------------------------------------------------------
function log.info(msg, save)   log.log("[INFO] " .. msg, save) end
function log.warn(msg, save)   log.log("[WARN] " .. msg, save) end
function log.error(msg, save)  log.log("[ERROR] " .. msg, save) end

------------------------------------------------------------
-- API: auto-wrap & replace functions to log inputs + outputs
-- Example:
--   log.g(gg)  --> wraps every function in gg
--   log.g({myFunc = someFunc})
--   log.g(myFunc)
------------------------------------------------------------
function log.wrap(target)
    local function safeToString(v)
        local ok, s = pcall(function() return tostring(v) end)
        return ok and s or "<unprintable>"
    end

    local function wrap(fn, name)
        if type(fn) ~= "function" then return fn end

        return function(...)
            -- collect args
            local args = {...}
            local argStrs = {}
            for i, v in ipairs(args) do
                table.insert(argStrs, safeToString(v))
            end

            local argList = table.concat(argStrs, ", ")
            log.log(string.format("[FUNC:%s] called with (%s)", name or "unknown", argList))

            -- call function safely
            local results = {fn(...)}
            local resStrs = {}
            for i, v in ipairs(results) do
                table.insert(resStrs, safeToString(v))
            end

            log.log(string.format("[FUNC:%s] returned (%s)", name or "unknown", table.concat(resStrs, ", ")))

            return table.unpack(results)
        end
    end

    if type(target) == "table" then
        -- wrap all functions in table (like gg)
        for k, v in pairs(target) do
            if type(v) == "function" then
                target[k] = wrap(v, tostring(k))
            end
        end
        return target

    elseif type(target) == "function" then
        return wrap(target, "anonymous")

    else
        log.error("log.wrap() expects a function or table")
    end
end

------------------------------------------------------------
-- Example Usage
------------------------------------------------------------
--[[
local log = require("log")

log.setPath("/sdcard/myapp.log")
log.info("App started", true)
log.warn("Low memory", true)
log.error("Network lost", true)

print(log.get())       -- show all logs
log.remove(true)       -- clear memory + file
--]]

return log
