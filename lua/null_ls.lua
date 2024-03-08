local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		null_ls.builtins.completion.tags,
		null_ls.builtins.diagnostics.trail_space,
		-- null_ls.builtins.diagnostics.vint,
		null_ls.builtins.formatting.isort,
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.yapf,
	},
})
