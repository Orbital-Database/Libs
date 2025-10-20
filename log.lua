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
