return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,

    opts = {},
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "folke/neodev.nvim",
    opts = {
      library = {
        plugins = { "nvim-dap-ui" },
        types = true,
      },
    },
  },
  "neovim/nvim-lspconfig",
  "tpope/vim-commentary",
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",

    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = { 
          "rust",
          "haskell",
          "java",
          "c_sharp",
          "go",
          "lua",
          "json",
        },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        no_italic = true,
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = function()
      require("ibl").setup()
    end,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "v2.8.0",
    config = true,
    opts = {
      open_mapping = [[<c-\>]],
    },
  },
  'mfussenegger/nvim-jdtls',

  -- Debugging via DAP
  {
    'mfussenegger/nvim-dap',
    version = "0.7.0",
  },
  {
    "rcarriga/nvim-dap-ui",
    config = true,
  },

  -- Code completion
  "neovim/nvim-lspconfig",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/nvim-cmp",

  -- luasnip
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
}

