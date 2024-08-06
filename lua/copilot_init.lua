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
		ExplainBrief = {
			prompt = "/COPILOT_EXPLAIN Write a brief explanation for the selection as paragraphs of text.",
		},
		Tests = {
			prompt = "/COPILOT_GENERATE Please generate tests for my code using pytest.",
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

vim.g.CopilotQuickChat = function(mode)
	local prompt = "Ask ChatGPT (" .. mode .. " selection): "
	local command = "CopilotChat" .. mode .. " "
	vim.ui.input({ prompt = prompt }, function(query)
		if query == nil then
			return
		end
		vim.cmd(command .. query)
	end)
end

-- Automated git commit messages
vim.g.CopilotCommitMsg = function()
	chat.ask(
		"Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Don't include any text except for the commit message in your output, because this text will be used for automated git commit messages. Don't wrap in ```",
		{
			selection = select.gitdiff,
			callback = function(response)
				-- Save response to a file
				local file_path = "/tmp/copilot_commit_msg"
				local file = io.open(file_path, "w")
				file:write(response)
				file:close()
				vim.cmd("silent Git add -A")
				vim.cmd("silent Git commit -F " .. file_path)
				vim.cmd("Git push")
			end,
		}
	)
	-- chat.close()
end
