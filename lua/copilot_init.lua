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

vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
	chat.ask(args.args, { selection = select.buffer })
end, { nargs = "*", range = true })

vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
	chat.ask(args.args, { selection = select.visual })
end, { nargs = "*", range = true })

_G.CopilotQuickChat = function(mode)
	local prompt = "Ask ChatGPT (" .. mode .. " selection): "
	local command = "CopilotChat" .. mode .. " "
	vim.ui.input({ prompt = prompt }, function(query)
		if query == nil then
			return
		end
		vim.cmd(command .. query)
	end)
end
