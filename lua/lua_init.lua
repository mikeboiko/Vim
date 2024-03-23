require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
	filetypes = {
		markdown = true,
		yaml = true,
		gitcommit = true,
	},
})

require("copilot_cmp").setup()

require("dressing").setup({
	input = {
		insert_only = false,
		start_in_insert = false,
	},
})
