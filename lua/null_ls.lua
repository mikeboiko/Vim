local null_ls = require("null-ls")

-- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md

null_ls.setup({
	sources = {
		null_ls.builtins.completion.tags,
		null_ls.builtins.diagnostics.trail_space,
		null_ls.builtins.diagnostics.sqlfluff.with({
			extra_args = { "--dialect", "tsql", "--exclude-rules", "CP02" },
		}),
		-- null_ls.builtins.diagnostics.vint,
		null_ls.builtins.formatting.isort,
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.formatting.sqlfluff.with({
			extra_args = { "--dialect", "tsql", "--exclude-rules", "CP02" },
		}),
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.yapf,
	},
})
