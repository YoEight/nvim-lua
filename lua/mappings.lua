local common = require 'common'

-- Telescope
common.map('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>")
common.map('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>")
common.map('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>")
common.map('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>")

-- Nvim Tree
common.map('n', '<C-n>', ':NvimTreeToggle<cr>')
common.map('n', '<leader>r', ':NvimTreeRefresh<cr>')
common.map('n', '<leader>n', ':NvimTreeFindFile<cr>')

vim.cmd [[highlight NvimTreeFolderIcon guibg=blue]]
