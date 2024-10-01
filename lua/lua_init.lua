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

require("ts_context_commentstring").setup({
	enable_autocmd = false,
})

require("mini.comment").setup({
	-- Options which control module behavior
	options = {
		-- Function to compute custom 'commentstring' (optional)
		custom_commentstring = function()
			return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
		end,

		-- Whether to ignore blank lines when commenting
		ignore_blank_line = true,

		-- Whether to force single space inner padding for comment parts
		pad_comment_parts = true,
	},

	-- Module mappings. Use `''` (empty string) to disable one.
	mappings = {
		-- Toggle comment (like `gcip` - comment inner paragraph) for both
		-- Normal and Visual modes
		comment = "gc",

		-- Toggle comment on current line
		comment_line = "cl",

		-- Toggle comment on visual selection
		comment_visual = "cl",

		-- Define 'comment' textobject (like `dgc` - delete whole comment block)
		-- Works also in Visual mode if mapping differs from `comment_visual`
		textobject = "gc",
	},
})
