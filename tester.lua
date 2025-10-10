test = {}

function test.ptrace()
	local address = gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE | gg.PROT_EXEC, 0)
	return address ~= 0
end

function test.internet()
	local url = "http://clients3.google.com/generate_204"
	local response = gg.makeRequest(url)
	return response and response.status == 204
end

function test.installer()
	local target = gg.getTargetInfo()
	return target.installer == "" or target.installer == "android"
end

function test.rooted()
	local target = gg.getTargetInfo()
	local path = "/data/data/" .. target.packageName .. "/"
	
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

function test.pointer(value, expected)
	local value = {{
		address = value
	}}
	local region = gg.getValuesRange(value)
	return region[1] == expected
end

function test.is64bit()
	local target = gg.getTargetInfo()
	return target.x64 == true
end

function test.isRestarted(filePath)
	local target = gg.getTargetInfo()
	local currentPid = target.pid

	local oldPid
	local f = io.open(filePath, "r")
	if f then
		oldPid = tonumber(f:read("*all"))
		f:close()
	end

	f = io.open(filePath, "w")
	if f then
		f:write(tostring(currentPid))
		f:close()
	end

	if oldPid == nil then
		return true
	end
	return oldPid == currentPid
end

return test