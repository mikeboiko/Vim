-- For Troubleshooting/Help, run:
-- :LspLog
-- :LspInfo
-- :help lsp-zero-keybindings

-- To learn what capabilities are available you can run the following command in
-- a buffer with a started LSP client: >vim
-- :lua =vim.lsp.get_clients()[1].server_capabilities
-- Note, I tried to get LSP file renaming to work with pyright, but pyright
-- doesn't have the proper workspace capabilities.
-- This is the plugin I tried
-- https://github.com/antosha417/nvim-lsp-file-operations?tab=readme-ov-file

local lsp_zero = require("lsp-zero")

lsp_zero.on_attach(function(client, bufnr)
	lsp_zero.default_keymaps({ buffer = bufnr })
	vim.keymap.set("n", "<leader>h", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
	vim.keymap.set("n", "<leader>fr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
	vim.keymap.set("n", "gR", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
	vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
	vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)
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
		["null-ls"] = { "python", "markdown", "lua", "vim", "vue", "yaml", "json", "sql", "javascript", "css", "scss" },
	},
})

-- Setup language servers.
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
local lspconfig = require("lspconfig")

lspconfig.bashls.setup({})

lspconfig.pyright.setup({
	init_options = {
		settings = {
			args = {},
		},
	},
})

-- npm install -g @vue/language-server
lspconfig.volar.setup({
	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
	init_options = {
		typescript = {
			tsdk = "/home/mike/npm-global/lib/node_modules/typescript/lib",
		},
		vue = {
			hybridMode = false,
		},
	},
})

-- First, install `omnisharp-roslyn` from AUR
local pid = vim.fn.getpid()
lspconfig.omnisharp.setup({
	cmd = { "/usr/bin/omnisharp", "--languageserver", "--hostPID", tostring(pid) },
})

-- Key mappings
vim.api.nvim_set_keymap("n", "<Leader>se", "<cmd>lua vim.diagnostic.setqflist()<CR>", { noremap = true, silent = true })
