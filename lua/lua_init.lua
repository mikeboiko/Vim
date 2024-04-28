require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
	filetypes = {
		markdown = true,
		yaml = true,
		gitcommit = true,
	},
})

-- TODO-MB [240426] - Move to new lua file
local chat = require("CopilotChat")
local select = require("CopilotChat.select")
require("CopilotChat").setup({
	debug = true, -- Enable debugging
	prompts = {
		ExplainBuffer = {
			prompt = "/COPILOT_EXPLAIN Write an explanation for the selection as paragraphs of text.",
			selection = select.buffer,
		},
	},
	mappings = {
		reset = {
			normal = "<C-r>",
			insert = "<C-r>",
		},
	},
})

-- TODO-MB [240426] - Add CopilotChatVisual
vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
	chat.ask(args.args, { selection = select.buffer })
end, { nargs = "*", range = true })

-- TODO-MB [240426] - Rename func
_G.myQuickChatFunction = function()
	vim.ui.input({ prompt = "Ask ChatGPT (buffer selected): " }, function(query)
		if query == nil then
			return
		end
		vim.cmd("CopilotChatBuffer " .. query)
	end)
end

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
