-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
if vim.fn.executable("gitui") == 1 then
  -- gitui instead of lazygit
  vim.keymap.set("n", "<leader>gG", function() require("lazyvim.util").float_term({ "gitui" }, { esc_esc = false, ctrl_hjkl = false }) end, { desc = "gitui (cwd)" })
  vim.keymap.set("n", "<leader>gg", function() require("lazyvim.util").float_term({ "gitui" }, { cwd = require("lazyvim.util").get_root(), esc_esc = false, ctrl_hjkl = false }) end, { desc = "gitui (root dir)" })
end

if vim.fn.executable("btop") == 1 then
  -- btop
  vim.keymap.set("n", "<leader>xb", function() require("lazyvim.util").float_term({ "btop" }, { esc_esc = false, ctrl_hjkl = false }) end, { desc = "btop" })
end

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
  end
end
-- 设置option常量
local opt = { noremap = true, silent = true }
-- 关闭搜索高亮
map({ 'n' }, '<leader>nh', ':nohlsearch<CR>', opt)
-- search/replace
map({ "n" }, "<A-r>", ":%s///g<left><left><left>", { noremap = true, silent = false })
map({ "n" }, "<C-a>", "gg0vG$", opt)

-- 在visual mode 里粘贴不要复制
map({ "v" }, "p", '"_dP', opt)
map({ "v" }, "gp", '"+p', opt)

map({ "n" }, "n", "nzzzv", opt)
map({ "n" }, "N", "Nzzzv", opt)
map({ "n" }, "<C-u>", "<C-u>zz", opt)
map({ "n" }, "<C-d>", "<C-d>zz", opt)
