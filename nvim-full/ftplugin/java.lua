-- ftplugin/java.lua
-- This file is sourced automatically when opening a .java file

local bufnr = vim.api.nvim_get_current_buf()

local jdtls = require 'jdtls'
local jdtls_setup = require 'jdtls.setup'

-- Find Mason installation paths
local mason_path = vim.fn.stdpath 'data' .. '/mason'
local jdtls_path = mason_path .. '/packages/jdtls'
local java_debug_path = mason_path .. '/packages/java-debug-adapter'
local java_test_path = mason_path .. '/packages/java-test'
local lombok_path = jdtls_path .. '/lombok.jar'

-- Find the jdtls launcher jar
local function get_jdtls_jar()
  local jar_patterns = {
    jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar',
  }
  for _, pattern in ipairs(jar_patterns) do
    local matches = vim.fn.glob(pattern, true, true)
    if #matches > 0 then
      return matches[1]
    end
  end
  return nil
end

-- Determine the OS-specific config directory
local function get_jdtls_config_dir()
  if vim.fn.has 'mac' == 1 then
    return jdtls_path .. '/config_mac'
  elseif vim.fn.has 'unix' == 1 then
    return jdtls_path .. '/config_linux'
  elseif vim.fn.has 'win32' == 1 then
    return jdtls_path .. '/config_win'
  end
  return jdtls_path .. '/config_linux'
end

-- Get project name for workspace directory
local function get_project_name()
  local cwd = vim.fn.getcwd()
  return vim.fn.fnamemodify(cwd, ':p:h:t')
end

-- Detect root directory - prioritize .git to get the actual project root
-- This is important for monorepos or projects with nested modules
local root_dir = jdtls_setup.find_root { '.git' }
if not root_dir then
  -- Fallback to other markers if .git not found
  root_dir = jdtls_setup.find_root { 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
end

if not root_dir then
  return -- No Java project root found, don't attach JDTLS
end

-- Setup workspace directory (one per project)
local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. get_project_name()
vim.fn.mkdir(workspace_dir, 'p')

-- Setup debugging bundles
local bundles = {}

-- Add java-debug-adapter (for debugging support)
local java_debug_jar = java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'
local debug_jars = vim.fn.glob(java_debug_jar, true, true)
if #debug_jars > 0 then
  vim.list_extend(bundles, debug_jars)
end

-- Add java-test (for test runner support - fixed in v0.43.2)
local java_test_jars = vim.fn.glob(java_test_path .. '/extension/server/*.jar', true, true)
if #java_test_jars > 0 then
  vim.list_extend(bundles, java_test_jars)
end

-- Get capabilities from nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Extended client capabilities for jdtls
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

-- Use currently active Java version from environment
-- This respects version managers (jenv, sdkman, version-fox, etc.)
local java_cmd = 'java'

-- JDTLS configuration
local config = {
  cmd = {
    java_cmd,
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    -- Enable Lombok support
    '-javaagent:' .. lombok_path,
    '-jar',
    get_jdtls_jar(),
    '-configuration',
    get_jdtls_config_dir(),
    '-data',
    workspace_dir,
  },

  root_dir = root_dir,

  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = 'interactive',
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      format = {
        enabled = true,
        settings = {
          url = vim.fn.expand('~/.config/work/marshmallow-eclipse.xml'),
          profile = 'marshmallow',
        },
      },
    },
    signatureHelp = { enabled = true },
    completion = {
      favoriteStaticMembers = {
        'org.hamcrest.MatcherAssert.assertThat',
        'org.hamcrest.Matchers.*',
        'org.hamcrest.CoreMatchers.*',
        'org.junit.jupiter.api.Assertions.*',
        'java.util.Objects.requireNonNull',
        'java.util.Objects.requireNonNullElse',
        'org.mockito.Mockito.*',
      },
      importOrder = {
        'java',
        'javax',
        'com',
        'org',
      },
    },
    extendedClientCapabilities = extendedClientCapabilities,
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      },
    },
    codeGeneration = {
      toString = {
        template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
      },
      useBlocks = true,
    },
  },

  flags = {
    allow_incremental_sync = true,
  },

  capabilities = capabilities,

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  init_options = {
    bundles = bundles,
  },

  -- Keymaps and other on_attach stuff
  on_attach = function(client, bufnr)
    -- Enable inlay hints if supported (shows parameter names, inferred types, etc.)
    if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    -- Use which-key for all keymaps
    require('which-key').add {
      -- LSP navigation
      { 'gd', vim.lsp.buf.definition, desc = 'Go to definition', buffer = bufnr },
      { 'gD', vim.lsp.buf.declaration, desc = 'Go to declaration', buffer = bufnr },
      { 'gi', vim.lsp.buf.implementation, desc = 'Go to implementation', buffer = bufnr },
      { 'gt', vim.lsp.buf.type_definition, desc = 'Go to type definition', buffer = bufnr },
      {
        'gr',
        function()
          require('telescope.builtin').lsp_references()
        end,
        desc = 'Find references (usages)',
        buffer = bufnr,
      },
      { 'K', vim.lsp.buf.hover, desc = 'Hover', buffer = bufnr },
      {
        '<C-k>',
        vim.lsp.buf.signature_help,
        desc = 'Signature help (parameter hints)',
        buffer = bufnr,
        mode = 'i',
      },
      { '[d', vim.diagnostic.goto_prev, desc = 'Prev diagnostic', buffer = bufnr },
      { ']d', vim.diagnostic.goto_next, desc = 'Next diagnostic', buffer = bufnr },

      -- Java group
      { '<leader>j', group = '[J]ava', buffer = bufnr },
      { '<leader>jo', jdtls.organize_imports, desc = '[O]rganize imports', buffer = bufnr },
      {
        '<leader>jr',
        function()
          require('telescope.builtin').lsp_references()
        end,
        desc = 'Find [R]eferences (usages)',
        buffer = bufnr,
      },
      {
        '<leader>ji',
        function()
          require('telescope.builtin').lsp_incoming_calls()
        end,
        desc = '[I]ncoming calls (who calls this)',
        buffer = bufnr,
      },
      {
        '<leader>jO',
        function()
          require('telescope.builtin').lsp_outgoing_calls()
        end,
        desc = '[O]utgoing calls (what this calls)',
        buffer = bufnr,
      },
      {
        '<leader>js',
        function()
          require('telescope.builtin').lsp_document_symbols()
        end,
        desc = '[S]ymbols in file (methods/fields)',
        buffer = bufnr,
      },
      {
        '<leader>jS',
        function()
          require('telescope.builtin').lsp_dynamic_workspace_symbols()
        end,
        desc = '[S]ymbols in workspace (search project)',
        buffer = bufnr,
      },
      {
        '<leader>jh',
        function()
          require('jdtls').super_implementation()
        end,
        desc = 'Go to super [H]ierarchy (parent class/method)',
        buffer = bufnr,
      },
      {
        '<leader>jH',
        function()
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
          end
        end,
        desc = 'Toggle inlay [H]ints (type annotations)',
        buffer = bufnr,
      },
      { '<leader>jv', jdtls.extract_variable, desc = 'Extract [V]ariable', buffer = bufnr, mode = 'n' },
      {
        '<leader>jv',
        [[<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>]],
        desc = 'Extract [V]ariable',
        buffer = bufnr,
        mode = 'v',
      },
      { '<leader>jc', jdtls.extract_constant, desc = 'Extract [C]onstant', buffer = bufnr, mode = 'n' },
      {
        '<leader>jc',
        [[<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>]],
        desc = 'Extract [C]onstant',
        buffer = bufnr,
        mode = 'v',
      },
      {
        '<leader>jm',
        [[<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>]],
        desc = 'Extract [M]ethod',
        buffer = bufnr,
        mode = 'v',
      },

      -- Testing group
      { '<leader>t', group = '[T]est', buffer = bufnr },
      { '<leader>tc', jdtls.test_class, desc = 'Test [C]lass', buffer = bufnr },
      { '<leader>tm', jdtls.test_nearest_method, desc = 'Test [M]ethod', buffer = bufnr },

      -- Code actions and generation
      { '<leader>c', group = '[C]ode', buffer = bufnr },
      { '<leader>ca', vim.lsp.buf.code_action, desc = 'Code [A]ction', buffer = bufnr },
      { '<leader>cg', group = '[G]enerate Code', buffer = bufnr },
      {
        '<leader>cgg',
        function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.kind and action.kind:match 'source.generate'
            end,
            apply = true,
          }
        end,
        desc = '[G]enerate (getters/setters/etc)',
        buffer = bufnr,
      },
      {
        '<leader>cgc',
        function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'constructor'
            end,
            apply = true,
          }
        end,
        desc = 'Generate [C]onstructor',
        buffer = bufnr,
      },
      {
        '<leader>cgt',
        function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'toString'
            end,
            apply = true,
          }
        end,
        desc = 'Generate [T]oString',
        buffer = bufnr,
      },
      {
        '<leader>cge',
        function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'equals' or action.title:match 'hashCode'
            end,
            apply = true,
          }
        end,
        desc = 'Generate [E]quals/HashCode',
        buffer = bufnr,
      },
      {
        '<leader>cgi',
        function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'Implement' or action.title:match 'Override'
            end,
            apply = true,
          }
        end,
        desc = '[I]mplement/Override methods',
        buffer = bufnr,
      },

      -- Rename
      { '<leader>r', group = '[R]ename', buffer = bufnr },
      { '<leader>rn', vim.lsp.buf.rename, desc = 'Re[n]ame', buffer = bufnr },

      -- Diagnostics/Formatting
      { '<leader>f', group = '[F]ormat/Fix', buffer = bufnr },
      {
        '<leader>fd',
        function()
          vim.diagnostic.open_float { border = 'rounded' }
        end,
        desc = 'Line [D]iagnostics',
        buffer = bufnr,
      },
      {
        '<leader>fl',
        function()
          require('telescope.builtin').diagnostics({ bufnr = 0 })
        end,
        desc = '[L]ist diagnostics in file',
        buffer = bufnr,
      },
      {
        '<leader>fL',
        function()
          require('telescope.builtin').diagnostics()
        end,
        desc = '[L]ist diagnostics in workspace',
        buffer = bufnr,
      },
      {
        '<leader>ff',
        function()
          vim.lsp.buf.format { async = true }
        end,
        desc = '[F]ormat buffer',
        buffer = bufnr,
      },
    }

    -- Register JDTLS commands
    jdtls.setup.add_commands()

    -- Setup DAP (debugging)
    jdtls.setup_dap { hotcodereplace = 'auto' }
    require('jdtls.dap').setup_dap_main_class_configs()
  end,
}

-- Start jdtls
jdtls.start_or_attach(config)

-- Ensure client attaches to this buffer (workaround for attachment issue)
-- This is especially important for session restoration
local function ensure_attach()
  local current_buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ name = 'jdtls' })
  if #clients > 0 then
    local client = clients[1]
    local attached_buffers = vim.lsp.get_buffers_by_client_id(client.id)
    local is_attached = false
    for _, buf in ipairs(attached_buffers) do
      if buf == current_buf then
        is_attached = true
        break
      end
    end
    if not is_attached then
      vim.lsp.buf_attach_client(current_buf, client.id)
    end
  end
end

-- Try multiple times with increasing delays to handle session restoration
vim.defer_fn(ensure_attach, 500)
vim.defer_fn(ensure_attach, 1500)
vim.defer_fn(ensure_attach, 3000)

-- Add commands for debugging and restarting
vim.api.nvim_create_user_command('JavaDebugBundles', function()
  print('Bundles loaded: ' .. #bundles)
  for i, bundle in ipairs(bundles) do
    print(i .. ': ' .. bundle)
  end
end, {})

vim.api.nvim_create_user_command('JavaCheckTestSupport', function()
  local clients = vim.lsp.get_clients({ bufnr = 0, name = 'jdtls' })
  if #clients == 0 then
    print('No jdtls client attached!')
    return
  end

  local client = clients[1]
  print('JDTLS client found: ' .. client.name)
  print('Client ID: ' .. client.id)

  -- Check if the client has the test capability
  if client.server_capabilities then
    print('Server capabilities present')
    if client.server_capabilities.executeCommandProvider then
      print('Execute command provider available')
      if client.server_capabilities.executeCommandProvider.commands then
        print('All available commands (' .. #client.server_capabilities.executeCommandProvider.commands .. ' total):')
        for _, cmd in ipairs(client.server_capabilities.executeCommandProvider.commands) do
          print('  - ' .. cmd)
        end
      end
    end
  end

  -- Check init_options
  if client.config and client.config.init_options then
    print('Init options bundles count: ' .. #(client.config.init_options.bundles or {}))
  end
end, {})

vim.api.nvim_create_user_command('JavaRestart', function()
  vim.cmd('LspRestart')
end, {})

vim.api.nvim_create_user_command('JavaAttach', function()
  local current_buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ name = 'jdtls' })
  if #clients > 0 then
    local client = clients[1]
    vim.lsp.buf_attach_client(current_buf, client.id)
    print('JDTLS reattached to buffer ' .. current_buf)
  else
    print('No JDTLS client found. Try :JavaRestart')
  end
end, { desc = 'Force JDTLS to attach to current buffer' })

vim.api.nvim_create_user_command('JavaShowLogs', function()
  vim.cmd('LspLog')
end, {})
