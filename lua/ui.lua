vim.cmd [[colorscheme gruvbox-flat]]

vim.g.better_whitespace_enabled = false

require('lualine').setup {
  options = {
    theme = 'gruvbox-flat',
    component_separators = {'\\', '/'},
    section_separators = {'◣', '◢'},
  }
}
