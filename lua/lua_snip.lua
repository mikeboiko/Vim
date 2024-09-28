local ls = require("luasnip")
local t = ls.text_node
local s = ls.snippet

-- ls.add_snippets("all", {

ls.add_snippets("markdown", {
	s("cb", { t("- [ ] ") }),
})

vim.keymap.set({ "i", "s" }, "<Tab>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	else
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
	end
end, { silent = true })
