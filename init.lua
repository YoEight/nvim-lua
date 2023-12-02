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
vim.o.showmode =  false
vim.o.wildmode = 'list:longest'
vim.o.showmatch = true
vim.o.signcolumn = 'yes'
vim.o.clipboard = 'unnamedplus'
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

local home = os.getenv("HOME")
local omnisharp_home = os.getenv("OMNISHARP_HOME")
local lua_ls_home = os.getenv("LUA_LS_HOME")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lsp_servers = {
  rust_analyzer = {
    capabilities = capabilities,
  },

  omnisharp = {
    cmd = { "dotnet", omnisharp_home .. "/OmniSharp.dll" },
    capabilities = capabilities,
  },

  lua_ls = {
    cmd = { lua_ls_home .. "/bin/lua-language-server" },
    capabilities = capabilities,
  },

  gopls = {
    capabilities = capabilities,
  },
}

local codelldb_home = os.getenv("CODELLDB_HOME")
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
      type = "codelldb",
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

local lsp = require("lspconfig")
for server, args in pairs(lsp_servers) do
  lsp[server].setup(args)
end

local dap = require("dap")
for adapter, args in pairs(dap_adapters) do
  dap.adapters[adapter] = args
end

for configuration, args in pairs(dap_configurations) do
  dap.configurations[configuration] = args
end

wk.register({
  ["<leader>"] = {
    a = { ":lua vim.lsp.buf.add_workspace_folder()<cr>", "Add Workspace Folder" },
    w = {
      name = "+window",
      w = { ":wincmd w<cr>", "Focus to previous window" },
      j = { ":wincmd j<cr>", "Focus to window from below" },
      h = { ":wincmd h<cr>", "Focus to window from the left" },
      k = { ":wincmd k<cr>", "Focus to window from the top" },
      l = { ":wincmd l<cr>", "Focus to window from the right" },
      c = { ":wincmd c<cr>", "Close current window" },
      v = { ":vsplit<cr>", "Split current window vertically" },
      s = { ":split<cr>", "Split current window horizontally" },
      ["<"] = { ":vert res -10<cr>", "Decrease focused split columns by 10" },
      [">"] = { ":vert res +10<cr>", "Increase focused split columns by 10" },
      ["-"] = { ":res res -10<cr>", "Decrease focused split rows by 10" },
      ["+"] = { ":res res +10<cr>", "Increase focused split rows by 10" },
    },

    f = {
      name = "+file",
      t = { "<cmd>Neotree toggle reveal<cr>",  "Toggle NeoTree" },
      n = { "<cmd>enew<cr>", "New File" },
      f = { "<cmd>Telescope find_files<cr>", "Find files" },
      b = { "<cmd>Telescope buffers<cr>", "Find buffers" },
      g = { "<cmd>Telescope live_grep<cr>", "Search for a string in current working directory" },
      o = { "<cmd>Telescope oldfiles<cr>", "List previously open files" },
      m = { "<cmd>Telescope man_pages<cr>", "List manpage entries" },
      c = {
        name = "+config",
        o = { ":e ~/.config/nvim/init.lua<cr>", "Open Config file" },
        p = { ":e ~/.config/nvim/lua/plugins.lua<cr>", "Open Plugins file" },
      }
    },

    c = {
      name = "+code",
      l = {
        name = "+list",
        d = {
          name = "+document",
          s = { "<cmd>Telescope lsp_document_symbols<cr>", "List Document Symbols" },
        },
        w = {
          name = "+workspace",
          s = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "List Workspace Symbols" },
        },
      },
      a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code action" },
      d = { "<cmd>Telescope diagnostics<cr>", "List Diagnostics for all open buffers" },
      f = { function() vim.lsp.buf.format { async = true } end,  "Format Current Buffer" },
      r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename symbol" },
    },

    b = { "<cmd>Telescope builtin<cr>", "List Built-in pickers and run them on <cr>" },

    d = {
      name = "+debug",
      b = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
      c = { "<cmd>lua require'dap'.continue()<cr>", "Resume Execution" },
      o = { "<cmd>lua require'dap'.step_over()<cr>", "Step Over Code" },
      i = { "<cmd>lua require'dap'.step_into()<cr>", "Step Into Code" },
      v = { "<cmd>lua require'dap'.repl.open()<cr>", "Inspect REPL State" },
      t = { "<cmd>lua require'dapui'.toggle()<cr>", "Toggle Dap UI"},
    },
  },

  g = {
    name = "+go",
    D = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Go to declaration" },
    d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Go to definition" },
    r = { "<cmd>lua vim.lsp.buf.references()<cr>", "Go to references" },
  },

  K = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Show type information" },
  ["<C-k>"] = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Show type information help" },
})
