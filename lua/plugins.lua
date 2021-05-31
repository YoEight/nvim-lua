vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'neovim/nvim-lspconfig'
    use 'eddyekofo94/gruvbox-flat.nvim'

    use {
        'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
    }

    use 'kyazdani42/nvim-web-devicons' -- for file icons
    use 'kyazdani42/nvim-tree.lua'

    use 'tpope/vim-commentary'

    use {
        'hoob3rt/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons', opt = true}
    }

    use 'glepnir/dashboard-nvim'
    use 'ntpeters/vim-better-whitespace'
end)
