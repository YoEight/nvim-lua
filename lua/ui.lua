-- vim.cmd [[colorscheme gruvbox-flat]]
require('onedark').setup()

vim.g.better_whitespace_enabled = false

require('lualine').setup {
  options = {
    theme = 'onedark',
    -- theme = 'gruvbox-flat',
    component_separators = {'\\', '/'},
    section_separators = {'◣', '◢'},
  }
}
