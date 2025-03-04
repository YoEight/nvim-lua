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
          "diff",
        },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        tools = {
          test_executor = 'background',
        },
      }
    end,
  },

  -- Colorschemes
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

  { 'projekt0n/github-nvim-theme', name = 'github-theme' },
  ---

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = function()
      require("ibl").setup({
      })
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
    version = "v2.13.0",
    config = true,
    opts = {
      open_mapping = [[<c-\>]],
    },
  },
  'mfussenegger/nvim-jdtls',

  -- Debugging via DAP
  {
    'mfussenegger/nvim-dap',
    version = "0.9.0",
    dependencies = { "nvim-neotest/nvim-nio" },
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

  { "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = { "github/copilot.vim"},
    build = "make tiktoken",
  },

  "f-person/auto-dark-mode.nvim",

  -- Testing
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter"
    }
  },

  "rouge8/neotest-rust",
  "Issafalcon/neotest-dotnet",
  --
}
