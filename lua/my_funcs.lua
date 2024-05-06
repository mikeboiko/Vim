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

local function get_visual_selection()
	local bufnr = vim.api.nvim_get_current_buf()
	local start_pos = vim.api.nvim_buf_get_mark(bufnr, "<")
	local end_pos = vim.api.nvim_buf_get_mark(bufnr, ">")
	local line = vim.api.nvim_buf_get_lines(bufnr, start_pos[1] - 1, start_pos[1], false)[1]
	local selection = string.sub(line, start_pos[2] + 1, end_pos[2] + 1)
	return selection
	-- print(selection)
end

vim.api.nvim_create_user_command("EchoSelection", get_visual_selection, { range = true })

vim.g.FancyPromptRename = function(func, prompt, visual)
	local original
	if visual then
		original = get_visual_selection()
	else
		original = vim.api.nvim_eval('expand("<cword>")')
	end
	vim.ui.input({ prompt = prompt, default = original }, function(query)
		if query == nil then
			return
		end
		-- vim.g.RenameWord(query, original)
		vim.g["RenameWord"](query, original)
	end)
end
