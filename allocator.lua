local alloc = {}

function alloc.order(pages)
	pages = pages or 256

	local startAddr = gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE)
	if not startAddr then
		gg.toast("ERROR allocatePage")
		return nil
	end

	local consec = {startAddr}
	for i = 1, pages - 1 do
		local want = startAddr + i * 0x1000
		local res = gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE, want)
		if res ~= want then
			break
		else
			table.insert(consec, res)
		end
	end

	local blockCount = #consec
	local size = blockCount * 0x1000

	return {
		type = "order",
		start = consec[1],
		["end"] = consec[#consec] + 0x1000,
		pages = blockCount,
		size = size
	}
end

function alloc.repeating(size)
	local start_addr
	for i = 1, size do
		start_addr = tonumber(gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE, start_addr))
		if i == 1 then
			end_addr = start_addr + 0x1000
		end
	end

	local actual_size
	for _, v in ipairs(gg.getRangesList()) do
		if v.start == start_addr then
			actual_size = v["end"] - v["start"]
		end
	end
	
	return {
		type = "repeating",
		["expected"] = end_addr - start_addr,
		["actual"] = actual_size,
		["start"] = start_addr
	}
end

return alloc
