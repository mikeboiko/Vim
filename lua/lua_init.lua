require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
	filetypes = {
		markdown = true,
		gitcommit = true,
	},
})

require("copilot_cmp").setup()
