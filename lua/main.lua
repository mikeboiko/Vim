if init_debug then
	require("osv").launch({ port = 8086, blocking = true })
end

require("dap-python").setup("/usr/bin/python")
require("dapui").setup()

local dap = require("dap")

dap.configurations.lua = {
	{
		type = "nlua",
		request = "attach",
		name = "Attach to running Neovim instance",
	},
}

dap.adapters.nlua = function(callback, config)
	callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
end

-- vim.keymap.set("n", "<leader>db", require("dap").toggle_breakpoint, { noremap = true })
-- vim.keymap.set("n", "<leader>dc", require("dap").continue, { noremap = true })
-- vim.keymap.set("n", "<leader>do", require("dap").step_over, { noremap = true })
-- vim.keymap.set("n", "<leader>di", require("dap").step_into, { noremap = true })

-- vim.keymap.set("n", "<leader>dl", function()
-- 	require("osv").launch({ port = 8086 })
-- end, { noremap = true })
