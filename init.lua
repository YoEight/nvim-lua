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
    java   = "setlocal tabstop=4 shiftwidth=4 expandtab",
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
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lsp_servers = {
  rust_analyzer = {
    capabilities = capabilities,
  },

  omnisharp = {
    cmd = { "dotnet", home .. "/lsp/omnisharp/OmniSharp.dll" },
    capabilities = capabilities,
  },

  lua_ls = {
    cmd = { home .. "/lsp/lua/bin/lua-language-server" },
    capabilities = capabilities,
  },
}

-- Specific install instructions for JTDLS (Java Language Server).
local java_root_markers = { "gradlew", ".git" }
local root_dir = vim.fs.dirname(vim.fs.find(java_root_markers, { upward = true })[1])
local java_workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, "p:h:t")
local jdtls = require("jdtls")
local jdtls_config = {
  capabilities = capabilities,
  cmd = {
    "/usr/lib/jvm/java-17-openjdk-amd64/bin/java",
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', home .. '/lsp/java/plugins/org.eclipse.equinox.launcher_1.6.500.v20230717-2134.jar',
    '-configuration', home .. '/lsp/java/config_linux',
    '-data', java_workspace_folder,
  },
  root_dir = root_dir,
  init_options = {
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
  },
  settings = {
    configuration = {
      runtimes = {
        {
          name = "JDK 11",
          path = "/usr/lib/jvm/java-11-openjdk-amd64/",
        },
        {
          name = "JDK 17",
          path = "/usr/lib/jvm/java-17-openjdk-amd64/",
        },
      }
    },
  },
}

local wk = require("which-key")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    wk.register({
      ["<leader>"] = {
        t = {
          name = "+test",
          c = { "<cmd>lua require'jdtls'.test_class()<cr>", "Run Java Test Class" },
          n = { "<cmd>lua require'jdtls'.test_nearest_method()<cr>", "Run Nearest Java Method Test Class" },
        }
      },
    })
    jdtls.start_or_attach(jdtls_config)
  end,
})

local lsp = require("lspconfig")
for server, args in pairs(lsp_servers) do
  lsp[server].setup(args)
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
      ["+"] = { ":res res -10<cr>", "Increase focused split rows by 10" },
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
        o = { ":e ~/.config/nvim/init.lua<cr>", "Open config file" },
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
