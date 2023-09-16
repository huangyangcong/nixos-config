-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- disable some extension providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- disable some fanzy UI stuff when run in Neovide
if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_floating_blur = 0
  vim.g.neovide_floating_opacity = 90
  vim.opt.guifont = 'FiraCode Nerd Font:h13'
end

-- general
vim.opt.guifont = "monospace:h13"               -- the font used in graphical neovim applications
vim.opt.foldmethod = "expr"                     -- folding, set to "expr" for treesitter based folding
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
-- 默认不要折叠
-- https://stackoverflow.com/questions/8316139/how-to-set-the-default-to-unfolded-when-you-open-a-file
vim.opt.foldlevel = 99

-- unnamed -> *  unnamedplus -> +
vim.opt.clipboard = { "unnamed", "unnamedplus" } -- use the system clipboard

-- translate
vim.g.translator_target_lang = "zh"
vim.g.translator_default_engines = {  'youdao', 'bing', 'haici'}
-- vim.g.translator_window_max_width = 200
-- vim.g.translator_window_max_height = 0.8

vim.opt.smartcase = true -- ignore case only with lowercase letters
vim.opt.wrap = true -- enable soft wrapping at the edge of the screen
vim.opt.linebreak = false -- don't wrap in the middle of a word
-- 光标在行首尾时<Left><Right>可以跳到下一行
vim.opt.whichwrap = vim.o.whichwrap .. "<,>,[,],h,l"
