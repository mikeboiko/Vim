vim.g.RenameWord = function(new, original)
	-- vim.api.nvim_echo({ { "New: " .. new .. " Original: " .. original } }, true, {})
	local buf = vim.api.nvim_get_current_buf()
	local start = 0
	local finish = -1
	local strict_indexing = false
	local lines = vim.api.nvim_buf_get_lines(buf, start, finish, strict_indexing)

	for i, line in ipairs(lines) do
		lines[i] = line:gsub(original, new)
	end

	vim.api.nvim_buf_set_lines(buf, start, finish, strict_indexing, lines)
end

vim.g.FuncFancyPromptRename = function(func, prompt)
	local original = vim.api.nvim_eval('expand("<cword>")')
	vim.ui.input({ prompt = prompt, default = original }, function(query)
		if query == nil then
			return
		end
		-- vim.g.RenameWord(query, original)
		vim.g["RenameWord"](query, original)
	end)
end
