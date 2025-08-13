function alloc(size)
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
	
	return {["expected"] = end_addr - start_addr, ["actual"] = actual_size, ["start"] = start_addr}
end

return alloc