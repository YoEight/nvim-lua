vim.g.mapleader = ' '

local common = require 'common'

-- Telescope
common.map('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>")
common.map('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>")
common.map('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>")
common.map('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>")

-- Nvim Tree
-- common.map('n', '<C-n>', ':NvimTreeToggle<cr>')
common.map('n', '<leader>r', ':NvimTreeRefresh<cr>')
common.map('n', '<leader>n', ':NvimTreeToggle<cr>')

-- Windows
common.map('n', '<leader>wv', ':vsplit<cr>')
common.map('n', '<leader>ws', ':split<cr>')
common.map('n', '<leader>wk', ':wincmd k<cr>')
common.map('n', '<leader>wj', ':wincmd j<cr>')
common.map('n', '<leader>wh', ':wincmd h<cr>')
-- For some reason, the mapping below is not working. Might have an overlapping keybinding.
common.map('n', '<leader>wl', ':wincmd l<cr>')
common.map('n', '<leader>ww', ':wincmd w<cr>')

-- Misc
common.map('n', '<leader>q', ':q<cr>')

vim.cmd [[highlight NvimTreeFolderIcon guibg=blue]]
