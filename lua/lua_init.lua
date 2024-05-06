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
