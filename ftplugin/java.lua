local home = os.getenv("HOME")
local jdtls_home = os.getenv("JDTLS_HOME")
local jdtls_launcher = os.getenv("JDTLS_LAUNCHER")
local java_debug_home = os.getenv("JAVA_DEBUG_HOME")
local vscode_java_test_home = os.getenv("VSCODE_JAVA_TEST_HOME")
local jdk11_home = os.getenv("JDK11_HOME")
local jdk17_home = os.getenv("JDK17_HOME")
local java_root_markers = { "gradlew", ".git" }
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local root_dir = vim.fs.dirname(vim.fs.find(java_root_markers, { upward = true })[1])
local java_workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, "p:h:t")
local jdtls = require("jdtls")
local bundles = {
  vim.fn.glob(java_debug_home .. "/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar", true)
}

vim.list_extend(bundles, vim.split(vim.fn.glob(vscode_java_test_home .. "/server/*.jar", true), "\n"))
local jdtls_config = {
  capabilities = capabilities,
  cmd = {
    jdk17_home .. "/bin/java",
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', jdtls_launcher,
    '-configuration', jdtls_home .. '/config_linux',
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
          path = jdk11_home,
        },
        {
          name = "JDK 17",
          path = jdk17_home,
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
