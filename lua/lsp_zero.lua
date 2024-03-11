-- For Troubleshooting/Help, run:
-- :LspLog
-- :LspInfo
-- :help lsp-zero-keybindings

local lsp_zero = require("lsp-zero")

lsp_zero.on_attach(function(client, bufnr)
	lsp_zero.default_keymaps({ buffer = bufnr })
	vim.keymap.set("n", "<leader>h", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
	vim.keymap.set("n", "<leader>fr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
	vim.keymap.set("n", "gR", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
	-- vim.keymap.set({ "n", "x" }, "<leader>fi", function()
	-- vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
	-- end, opts)
end)

lsp_zero.set_sign_icons({
	error = "✘",
	warn = "▲",
	hint = "⚑",
	info = "»",
})

-- `format_on_save` should run only once, before the language servers are active.
lsp_zero.format_on_save({
	format_opts = {
		async = false,
		timeout_ms = 10000,
	},
	servers = {
		["null-ls"] = { "python", "markdown", "lua", "vim", "yaml", "json" },
	},
})

-- Setup language servers.
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
local lspconfig = require("lspconfig")

lspconfig.bashls.setup({})

lspconfig.pyright.setup({
	init_options = {
		settings = {
			args = {},
		},
	},
})

-- Key mappings
vim.api.nvim_set_keymap("n", "<Leader>se", "<cmd>lua vim.diagnostic.setqflist()<CR>", { noremap = true, silent = true })
