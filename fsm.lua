--=========================================================
--  FSM (File System Manager) - Pure Lua 5.3
--=========================================================
local fsm = {}

-- Read a file as text
function fsm.read(path)
    local f = io.open(path, "r")
    if not f then return nil, "Cannot open file: " .. path end
    local data = f:read("*a")
    f:close()
    return data
end

-- Write text to file (overwrite)
function fsm.write(path, text)
    local f = io.open(path, "w")
    if not f then return false, "Cannot write to file: " .. path end
    f:write(text or "")
    f:close()
    return true
end

-- Append text to file
function fsm.append(path, text)
    local f = io.open(path, "a")
    if not f then return false, "Cannot append to file: " .. path end
    f:write(text or "")
    f:close()
    return true
end

-- Check if a file exists
function fsm.exists(path)
    local f = io.open(path, "r")
    if f then f:close() return true else return false end
end

-- Copy file (pure Lua)
function fsm.copy(src, dest)
    local content, err = fsm.read(src)
    if not content then return false, err end
    return fsm.write(dest, content)
end

-- Move file (pure Lua)
function fsm.move(src, dest)
    local ok, err = fsm.copy(src, dest)
    if not ok then return false, err end
    os.remove(src)
    return true
end

-- Delete file
function fsm.delete(path)
    return os.remove(path)
end

-- Rename file
function fsm.rename(old, new)
    return os.rename(old, new)
end

-- Read file line by line (returns table)
function fsm.readLines(path)
    local f = io.open(path, "r")
    if not f then return nil, "Cannot open file" end
    local lines = {}
    for line in f:lines() do
        table.insert(lines, line)
    end
    f:close()
    return lines
end

-- Create a new empty file
function fsm.touch(path)
    local f = io.open(path, "a")
    if not f then return false, "Cannot create file" end
    f:close()
    return true
end

-- Get file size (in bytes)
function fsm.size(path)
    local f = io.open(path, "r")
    if not f then return nil, "File not found" end
    local size = f:seek("end")
    f:close()
    return size
end

-- Duplicate file n times
function fsm.duplicate(src, count)
    local content = fsm.read(src)
    if not content then return false, "Cannot read source file" end
    for i = 1, count do
        fsm.write(src .. "_" .. i, content)
    end
    return true
end

--=========================================================
--  Example usage:
--=========================================================
--[[
local fsm = require("fsm")

fsm.write("test.txt", "Hello World!")
print(fsm.read("test.txt"))
fsm.append("test.txt", "\nNew line added")
fsm.copy("test.txt", "copy_test.txt")
print(fsm.size("test.txt"), "bytes")
fsm.move("copy_test.txt", "moved_test.txt")
fsm.delete("moved_test.txt")
--]]

return fsm
