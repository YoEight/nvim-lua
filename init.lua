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
-- vim.cmd.colorscheme "github_dark"

-- require('auto-dark-mode').setup({
-- 	update_interval = 1000,
-- 	set_dark_mode = function()
-- 		vim.api.nvim_set_option_value('background', 'dark', {})
-- 		vim.cmd('colorscheme github_dark_default')
-- 	end,
-- 	set_light_mode = function()
-- 		vim.api.nvim_set_option_value('background', 'light', {})
-- 		vim.cmd('colorscheme github_light_default')
-- 	end,
-- })
--
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
-- local omnisharp_home = os.getenv("OMNISHARP_HOME")
local lua_ls_home = home .. "/dev_env/lua-language-server"
-- local rust_ls_home = os.getenv("RUST_LS_HOME")
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
    cmd = { lua_ls_home .. "/bin/lua-language-server" },
    capabilities = capabilities,
  },

  gopls = {
    capabilities = capabilities,
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

local neotest = require("neotest")
neotest.setup({
  adapters = {
    require("rustaceanvim.neotest"),
    require("neotest-dotnet"),
  },
})

wk.add({
    { "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", desc = "Show type information help" },
    { "<leader>a", group = "ai" },
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
    { "<leader>at", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat" },
     -- { "<leader>a", ":lua vim.lsp.buf.add_workspace_folder()<cr>", desc = "Add Workspace Folder" },
    { "<leader>b", "<cmd>Telescope builtin<cr>", desc = "List Built-in pickers and run them on <cr>" },
    { "<leader>c", group = "code" },
    { "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code action" },
    { "<leader>cd", "<cmd>Telescope diagnostics<cr>", desc = "List Diagnostics for all open buffers" },
    { "<leader>cf", "<cmd>lua vim.lsp.buf.format()<cr>", desc = "Format Current Buffer" },
    { "<leader>cl", group = "list" },
    { "<leader>cld", group = "document" },
    { "<leader>clds", "<cmd>Telescope lsp_document_symbols<cr>", desc = "List Document Symbols" },
    { "<leader>clw", group = "workspace" },
    { "<leader>clws", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "List Workspace Symbols" },
    { "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename symbol" },
    { "<leader>d", group = "debug" },
    { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = "Toggle Breakpoint" },
    { "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", desc = "Resume Execution" },
    { "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", desc = "Step Into Code" },
    { "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", desc = "Step Over Code" },
    { "<leader>dt", "<cmd>lua require'dapui'.toggle()<cr>", desc = "Toggle Dap UI" },
    { "<leader>dv", "<cmd>lua require'dap'.repl.open()<cr>", desc = "Inspect REPL State" },
    { "<leader>df", "<cmd>lua require'dapui'.float_element()<cr>", desc = "Floating Element" },
    { "<leader>f", group = "file" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
    { "<leader>fc", group = "config" },
    { "<leader>fco", ":e ~/.config/nvim/init.lua<cr>", desc = "Open Config file" },
    { "<leader>fcp", ":e ~/.config/nvim/lua/plugins.lua<cr>", desc = "Open Plugins file" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Search for a string in current working directory" },
    { "<leader>fm", "<cmd>Telescope man_pages<cr>", desc = "List manpage entries" },
    { "<leader>fn", "<cmd>enew<cr>", desc = "New File" },
    { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "List previously open files" },
    { "<leader>ft", "<cmd>Neotree toggle reveal<cr>", desc = "Toggle NeoTree" },
    { "<leader>r", group = "run" },
    { "<leader>rt", "<cmd>lua require('neotest').run.run()<cr>", desc = "run nearest test" },
    { "<leader>rf", '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>', desc = "run current file tests" },
    { "<leader>rdt", '<cmd>lua require("neotest").run.run({strategy = "dap"})<cr>', desc = "debug nearest test" },
    { "<leader>rdf", '<cmd>lua require("neotest").run.run({vim.fn.expand("%"), strategy = "dap"})<cr>', desc = "debug current file tests" },
    { "<leader>rs", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = "toggle test summary" },
    { "<leader>w", group = "window" },
    { "<leader>w+", ":res res +10<cr>", desc = "Increase focused split rows by 10" },
    { "<leader>w-", ":res res -10<cr>", desc = "Decrease focused split rows by 10" },
    { "<leader>w<", ":vert res -10<cr>", desc = "Decrease focused split columns by 10" },
    { "<leader>w>", ":vert res +10<cr>", desc = "Increase focused split columns by 10" },
    { "<leader>wc", ":wincmd c<cr>", desc = "Close current window" },
    { "<leader>wh", ":wincmd h<cr>", desc = "Focus to window from the left" },
    { "<leader>wj", ":wincmd j<cr>", desc = "Focus to window from below" },
    { "<leader>wk", ":wincmd k<cr>", desc = "Focus to window from the top" },
    { "<leader>wl", ":wincmd l<cr>", desc = "Focus to window from the right" },
    { "<leader>ws", ":split<cr>", desc = "Split current window horizontally" },
    { "<leader>wv", ":vsplit<cr>", desc = "Split current window vertically" },
    { "<leader>ww", ":wincmd w<cr>", desc = "Focus to previous window" },
    { "K", "<cmd>lua vim.lsp.buf.hover()<cr>", desc = "Show type information" },
    { "g", group = "go" },
    { "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", desc = "Go to declaration" },
    { "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "Go to definition" },
    { "gr", "<cmd>lua vim.lsp.buf.references()<cr>", desc = "Go to references" },
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
