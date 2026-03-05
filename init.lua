local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

-- vim.o: for setting global options
-- vim.bo: for setting buffer-scoped options
-- vim.wo: for setting window-scoped options
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.termguicolors = true
vim.o.showmode = false
vim.o.wildmode = 'list:longest'
vim.o.showmatch = true
vim.o.signcolumn = 'yes'
vim.o.clipboard = 'unnamedplus'
vim.o.completeopt = 'menu,preview'
vim.wo.number = true
vim.wo.wrap = false
vim.wo.cursorline = true

local auto_cmds = {
  ["FileType"] = {
    lua    = "setlocal tabstop=2 shiftwidth=2 expandtab",
    rust   = "setlocal tabstop=4 shiftwidth=4 expandtab",
    csharp = "setlocal tabstop=4 shiftwidth=4 expandtab",
    go     = "setlocal tabstop=4 shiftwidth=4 expandtab",
  }
}

for group, cmds in pairs(auto_cmds) do
  for pat, cmd in pairs(cmds) do
    vim.api.nvim_create_autocmd(group, {
      pattern = pat,
      command = cmd,
    })
  end
end

require("lazy").setup("plugins")

vim.cmd.colorscheme "catppuccin-mocha"
vim.api.nvim_set_option_value('background', 'dark', {})

vim.diagnostic.config({
  virtual_text = false
});

require('lualine').setup({
  sections = {
    lualine_x = { "encoding", { "fileformat", symbols = { unix = "" } }, "filetype" },
  },

  options = {
    section_separators = { left = '\u{e0b8}', right = '\u{e0ba}' },
    component_separators = { left = '\u{e0b9}', right = '\u{e0bb}' }
  }
})
require('nvim-autopairs').setup({})


local lspkind = require('lspkind')
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ['<c-b>'] = cmp.mapping.scroll_docs(-4),
    ['<c-f>'] = cmp.mapping.scroll_docs(4),
    ['<c-Space>'] = cmp.mapping.complete(),
    ['<c-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),

  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }),
  {
    { name = "buffer" },
  },

  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = {
        -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
        -- can also be a function to dynamically calculate max width such as
        -- menu = function() return math.floor(0.45 * vim.o.columns) end,
        menu = 50,              -- leading text (labelDetails)
        abbr = 50,              -- actual suggestion item
      },
      ellipsis_char = '...',    -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
      show_labelDetails = true, -- show labelDetails in menu. Disabled by default

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function(entry, vim_item)
        -- ...
        return vim_item
      end
    })
  }
})

cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "buffer" },
  }),
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})

-- require('trouble').setup {}
require('neogit').setup {}

local on_attach = function(client, bufnr)
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format()
    end
  })
end

require('nvim-treesitter').setup {
  -- Directory to install parsers and queries
  install_dir = vim.fn.stdpath('data') .. '/site'
}
require('nvim-treesitter').install({ 'rust', 'haskell', 'java', 'c_sharp', 'go', 'lua', 'json', 'diff' })

local home = os.getenv("HOME")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lsp_servers = {
  -- rust_analyzer = {
  --   cmd = { rust_ls_home .. "/extension/server/rust-analyzer" },
  --   capabilities = capabilities,
  -- },

  -- omnisharp = {
  --   cmd = { "dotnet", omnisharp_home .. "/OmniSharp.dll" },
  --   capabilities = capabilities,
  -- },
  --
  --
  lua_ls = {
    --cmd = { lua_ls_home .. "/bin/lua-language-server" },
    capabilities = capabilities,
    on_attach = on_attach,
  },

  gopls = {
    capabilities = capabilities,
    on_attach = on_attach,
  },
}

local codelldb_home = home .. "/dev_env/codelldb"
local dap_adapters = {
  codelldb = {
    type = "server",
    port = "13000",
    executable = {
      command = codelldb_home .. "/extension/adapter/codelldb",
      args = { "--port", "13000" },
    }
  }
}

local dap_configurations = {
  rust = {
    {
      name = "Launch file",
      type = "codelld",
      request = "launch",
      program = function()
        return vim.fn.input({
          prompt = "Path to executable: ",
          default = vim.fn.getcwd() .. "/",
          completion = "file",
        })
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      sourceLanguages = { "rust" },
    },
    {
      name = "Attach to process",
      type = "codelldb",
      request = "attach",
      pid = require("dap.utils").pick_process,
      args = {},
    },
  },
}

local wk = require("which-key")

vim.lsp.enable('lua_ls')
vim.lsp.enable('gopls')
-- vim.lsp.config('lua_ls', {
-- capabilities = capabilities,
-- on_attach = on_attach,
-- })

-- vim.lsp.config('gopls', {
-- capabilities = capabilities,
-- on_attach = on_attach,
-- })

local dap = require("dap")
for adapter, args in pairs(dap_adapters) do
  dap.adapters[adapter] = args
end

for configuration, args in pairs(dap_configurations) do
  dap.configurations[configuration] = args
end

-- Gutter icon configurations
local signs = {
  Error = " ",
  Warn = " ",
  Hint = "󰌵 ",
  Info = " "
}

local signConf = {
  text = {},
  texthl = {},
  numhl = {},
}

for type, icon in pairs(signs) do
  local severityName = string.upper(type)
  local severity = vim.diagnostic.severity[severityName]
  local hl = "DiagnosticSign" .. type
  signConf.text[severity] = icon
  signConf.texthl[severity] = hl
  signConf.numhl[severity] = hl
end

vim.diagnostic.config({
  signs = signConf,
})

vim.g.rustaceanvim = {
  server = {
    on_attach = on_attach,
  }
}

local neotest = require("neotest")
neotest.setup({
  adapters = {
    require("rustaceanvim.neotest"),
    require("neotest-dotnet"),
  },
})

wk.add({
  { ",",           "<cmd>noh<cr>" },
  { "<C-\\>",      "<cmd>Lspsaga term_toggle<cr>",                                                    desc = "Toggle terminal",                                 mode = { "n", "t" } },
  -- { "<leader>k", "<cmd>lua vim.lsp.buf.signature_help()<cr>", desc = "Show type information help" },
  { "<leader>k",   "<cmd>Lspsaga hover_doc<cr>",                                                      desc = "Show type information" },
  { "<leader>a",   "<cmd>Lspsaga code_action<cr>",                                                    desc = "Code action" },
  -- { "<leader>a", ":lua vim.lsp.buf.add_workspace_folder()<cr>", desc = "Add Workspace Folder" },
  { "<leader>b",   "<cmd>Telescope buffers<cr>",                                                      desc = "Find buffers" },
  { "<leader>c",   "gcc",                                                                             desc = "Comment/uncomment selections",                    remap = true },
  { "<leader>g",   "<cmd>Neogit<cr>",                                                                 desc = "git" },
  -- { "<leader>c", group = "code" },
  { "<leader>o",   "<cmd>Lspsaga outline<cr>",                                                        desc = "Toggle buffer outline" },
  { "<leader>d",   "<cmd>Telescope diagnostics<cr>",                                                  desc = "List Diagnostics for all open buffers" },
  { "<leader>f",   "<cmd>Telescope find_files<cr>",                                                   desc = "Find files" },
  { "<leader>r",   "<cmd>Lspsaga rename<cr>",                                                         desc = "Rename symbol" },
  { "<leader>s",   "<cmd>Telescope lsp_document_symbols<cr>",                                         desc = "List Document Symbols" },
  { "<leader>S",   "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",                                desc = "List Workspace Symbols" },
  { "<leader>t",   "<cmd>Neotree toggle reveal<cr>",                                                  desc = "Toggle NeoTree" },
  { "<leader>y",   "+y",                                                                              desc = "Yank selections to clipboard" },
  -- { "<leader>cf", "<cmd>lua vim.lsp.buf.format()<cr>", desc = "Format Current Buffer" },
  { "<leader>D",   group = "debug" },
  { "<leader>Db",  "<cmd>lua require'dap'.toggle_breakpoint()<cr>",                                   desc = "Toggle Breakpoint" },
  { "<leader>Dc",  "<cmd>lua require'dap'.continue()<cr>",                                            desc = "Resume Execution" },
  { "<leader>Di",  "<cmd>lua require'dap'.step_into()<cr>",                                           desc = "Step Into Code" },
  { "<leader>Do",  "<cmd>lua require'dap'.step_over()<cr>",                                           desc = "Step Over Code" },
  { "<leader>Dt",  "<cmd>lua require'dapui'.toggle()<cr>",                                            desc = "Toggle Dap UI" },
  { "<leader>Dv",  "<cmd>lua require'dap'.repl.open()<cr>",                                           desc = "Inspect REPL State" },
  { "<leader>Df",  "<cmd>lua require'dapui'.float_element()<cr>",                                     desc = "Floating Element" },
  -- { "<leader>f", group = "file" },
  { "<leader>C",   group = "config" },
  { "<leader>Co",  ":e ~/.config/nvim/init.lua<cr>",                                                  desc = "Open Config file" },
  { "<leader>Cp",  ":e ~/.config/nvim/lua/plugins.lua<cr>",                                           desc = "Open Plugins file" },
  { "<leader>/",   "<cmd>Telescope live_grep<cr>",                                                    desc = "Search for a string in current working directory" },
  -- { "<leader>fm", "<cmd>Telescope man_pages<cr>", desc = "List manpage entries" },
  -- { "<leader>fn", "<cmd>enew<cr>", desc = "New File" },
  { "m",           "%",                                                                               desc = "Go to matching bracket",                          remap = true },
  { "<leader>R",   group = "run" },
  { "<leader>Rt",  "<cmd>lua require('neotest').run.run()<cr>",                                       desc = "run nearest test" },
  { "<leader>Rf",  '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>',                     desc = "run current file tests" },
  { "<leader>Rdt", '<cmd>lua require("neotest").run.run({strategy = "dap"})<cr>',                     desc = "debug nearest test" },
  { "<leader>Rdf", '<cmd>lua require("neotest").run.run({vim.fn.expand("%"), strategy = "dap"})<cr>', desc = "debug current file tests" },
  { "<leader>Rs",  "<cmd>lua require('neotest').summary.toggle()<cr>",                                desc = "toggle test summary" },
  { "<leader>w",   group = "window" },
  { "<leader>w+",  ":res res +10<cr>",                                                                desc = "Increase focused split rows by 10" },
  { "<leader>w-",  ":res res -10<cr>",                                                                desc = "Decrease focused split rows by 10" },
  { "<leader>w<",  ":vert res -10<cr>",                                                               desc = "Decrease focused split columns by 10" },
  { "<leader>w>",  ":vert res +10<cr>",                                                               desc = "Increase focused split columns by 10" },
  { "<leader>wc",  ":wincmd c<cr>",                                                                   desc = "Close current window" },
  { "<leader>wh",  ":wincmd h<cr>",                                                                   desc = "Focus to window from the left" },
  { "<leader>wj",  ":wincmd j<cr>",                                                                   desc = "Focus to window from below" },
  { "<leader>wk",  ":wincmd k<cr>",                                                                   desc = "Focus to window from the top" },
  { "<leader>wl",  ":wincmd l<cr>",                                                                   desc = "Focus to window from the right" },
  { "<leader>ws",  ":split<cr>",                                                                      desc = "Split current window horizontally" },
  { "<leader>wv",  ":vsplit<cr>",                                                                     desc = "Split current window vertically" },
  { "<leader>ww",  ":wincmd w<cr>",                                                                   desc = "Focus to previous window" },
  { "g",           group = "go" },
  { "gh",          "0",                                                                               desc = "Go to line start" },
  { "gl",          "$",                                                                               desc = "Go to line end" },
  { "gs",          "^",                                                                               desc = "Go to first non-blank in line" },
  { "ge",          "G",                                                                               desc = "Go to last line" },
  { "gD",          "<cmd>lua vim.lsp.buf.declaration()<cr>",                                          desc = "Go to declaration" },
  { "gd",          "<cmd>lua vim.lsp.buf.definition()<cr>",                                           desc = "Go to definition" },
  { "gr",          "<cmd>Lspsaga finder<cr>",                                                         desc = "Go to references" },
})

local copilot = require("CopilotChat")
copilot.setup({
  mappings = {
    complete = {
      detail = "Use @<Tab> or /<Tab> for options.",
      insert = "",
    },
  },

  keys = {
    {
      "<leader>ai",
      function()
        local input = vim.fn.input("ask copilot: ")
        if input ~= "" then
          vim.cmd("CopilotChat " .. input)
        end
      end,
      desc = "Ask Copilot"
    },
  }
})
