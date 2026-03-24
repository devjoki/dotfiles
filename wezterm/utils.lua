return {
	merge = function(tbls)
		local result = {}
		for _, tbl in ipairs(tbls) do
			for _, v in pairs(tbl) do
				table.insert(result, v)
			end
		end
		return result
	end,
}
