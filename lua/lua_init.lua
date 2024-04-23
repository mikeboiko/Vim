require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
	filetypes = {
		markdown = true,
		yaml = true,
		gitcommit = true,
	},
})

require("CopilotChat").setup({
	debug = true, -- Enable debugging
	-- See Configuration section for rest
})

require("copilot_cmp").setup()

require("dressing").setup({
	input = {
		insert_only = false,
		start_in_insert = false,
	},
})

require("bqf").setup({
	auto_enable = true,
	auto_resize_height = true,
	func_map = {
		split = "<C-s>",
		tabdrop = "<C-t>",
	},
})
