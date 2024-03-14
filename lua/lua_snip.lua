local ls = require("luasnip")
local t = ls.text_node
local s = ls.snippet

ls.add_snippets("all", {
	s("cb", { t("- [ ] ") }),
})

vim.keymap.set({ "i" }, "<TAB>", function()
	ls.expand()
end, { silent = true })

-- vim.keymap.set({ "i", "s" }, "<C-L>", function()
-- ls.jump(1)
-- end, { silent = true })
-- vim.keymap.set({ "i", "s" }, "<C-J>", function()
-- ls.jump(-1)
-- end, { silent = true })

-- vim.keymap.set({ "i", "s" }, "<C-E>", function()
-- if ls.choice_active() then
-- ls.change_choice(1)
-- end
-- end, { silent = true })
