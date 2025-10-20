--=========================================================
--  ANIME Library - Safe Anime Image Fetcher
--  (uses gg.makeRequest)
--=========================================================
local anime = {}

-- Helper: Get JSON safely
local function getJSON(url)
    local res = gg.makeRequest(url)
    if not res or not res.content then
        return nil, "Request failed"
    end
    local ok, data = pcall(function()
        local t = {}
        for k, v in res.content:gmatch('"(.-)"%s*:%s*"(.-)"') do
            t[k] = v
        end
        return t
    end)
    if not ok then return nil, "JSON parse error" end
    return data
end

-- Helper: Save binary data
local function saveFile(path, data)
    local f = io.open(path, "wb")
    if not f then return false, "Cannot save file" end
    f:write(data)
    f:close()
    return true
end

------------------------------------------------------------
-- Fetch from nekos.best API (SFW only)
------------------------------------------------------------
function anime.random()
    local endpoints = {
        "smile", "neko", "waifu", "pat", "hug", "cuddle", "wink",
        "sleep", "happy", "wave", "blush", "highfive"
    }
    local pick = endpoints[math.random(1, #endpoints)]
    local url = "https://nekos.best/api/v2/" .. pick
    local data, err = getJSON(url)
    if not data or not data.results then
        return nil, err or "Failed to fetch"
    end

    local imgURL = data.results:match('"url":"(.-)"')
    return imgURL or data.url
end

------------------------------------------------------------
-- Fetch from waifu.pics (SFW only)
------------------------------------------------------------
function anime.waifu()
    local data, err = getJSON("https://api.waifu.pics/sfw/waifu")
    if not data then return nil, err end
    return data.url
end

function anime.neko()
    local data, err = getJSON("https://api.waifu.pics/sfw/neko")
    if not data then return nil, err end
    return data.url
end

function anime.smile()
    local data, err = getJSON("https://api.waifu.pics/sfw/smile")
    if not data then return nil, err end
    return data.url
end

------------------------------------------------------------
-- Download an anime image
------------------------------------------------------------
function anime.download(url, path)
    local res = gg.makeRequest(url)
    if not res or not res.content then return false, "Failed to download" end
    return saveFile(path, res.content)
end

------------------------------------------------------------
-- Example Usage:
------------------------------------------------------------
--[[
local anime = require("anime")

local imgURL = anime.random()
print("Random anime image:", imgURL)

-- Download the image
local ok, msg = anime.download(imgURL, "/sdcard/anime_random.jpg")
print(ok, msg)
--]]

return anime
