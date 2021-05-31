-- vim.o: for setting global options
-- vim.bo: for setting buffer-scoped options
-- vim.wo: for setting window-scoped options

local indent = 4

vim.bo.expandtab = true -- Use spaces instead of tabs
vim.bo.shiftwidth = indent -- Size of the indent
vim.bo.smartindent = true -- Insert indents automatically
vim.bo.tabstop = indent -- Number of spaces tabs count for
vim.o.completeopt = 'menuone,noinsert,noselect' -- Completion options (for deoplete)
vim.o.hidden = true -- Enable modified buffers in background
vim.o.ignorecase = true -- Ignore case
vim.o.joinspaces = false -- No double spaces with join after a dot
vim.o.scrolloff = 4 -- Lines of context
vim.o.shiftround = true -- Round indent
vim.o.sidescrolloff = 8 -- Columns of context
vim.o.smartcase = true -- Don't ignore case with capitals
vim.o.splitbelow = true -- Put new window below current
vim.o.splitright = true -- Put new window right current
vim.o.termguicolors = true -- True color support
vim.o.wildmode = 'list:longest' -- Command-line completion mode
vim.o.showmode = false
vim.wo.list = true -- Show some invisible characters (tabs)
vim.wo.number = true -- Print line number
vim.wo.relativenumber = true -- Relative line numbers
vim.wo.wrap = false -- Disable line wrap
vim.wo.cursorline = true -- Enable highlighting of the current line
