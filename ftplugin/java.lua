local home = os.getenv("HOME")
local java_root_markers = { "gradlew", ".git" }
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local root_dir = vim.fs.dirname(vim.fs.find(java_root_markers, { upward = true })[1])
local java_workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, "p:h:t")
local jdtls = require("jdtls")
local bundles = {
  vim.fn.glob(home .. "/lsp/java/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar", true)
}

vim.list_extend(bundles, vim.split(vim.fn.glob(home .. "/lsp/java/vscode-java-test/server/*.jar", true), "\n"))
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
    bundles = bundles,
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
