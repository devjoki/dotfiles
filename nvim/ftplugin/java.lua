local home = os.getenv 'HOME'
local nvim_app_name = vim.env.NVIM_APPNAME or 'nvim'
local share_path = home .. '/.local/share/' .. nvim_app_name
local workspace_path = share_path .. '/jdtls-workspace/'
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = workspace_path .. project_name

local status, jdtls = pcall(require, 'jdtls')
if not status then
  print 'jdtls not found... exiting from java ftplugin...'
  return
end
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.onCompletionItemSelectedCommand = 'editor.action.triggerParameterHints'

local get_bundles = function()
  local jar_patterns = { share_path .. '/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar' }
  local bundles = {}
  local mason_registry = require 'mason-registry'
  if mason_registry.is_installed 'java-debug-adapter' and mason_registry.is_installed 'java-test' then
    vim.list_extend(jar_patterns, {
      share_path .. '/mason/packages/java-test/extension/server/*.jar',
    })
    for _, jar_pattern in ipairs(jar_patterns) do
      for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), '\n')) do
        table.insert(bundles, bundle)
      end
    end
  else
    -- TODO why this is not working
    print 'java denug adapter and java test must be installed!'
    vim.api.nvim_err_writeln 'java denug adapter and java test must be installed!'
  end
  return bundles
end

local config = {
  cmd = {
    'java',
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
    '-javaagent:' .. share_path .. '/mason/packages/jdtls/lombok.jar',
    '-jar',
    vim.fn.glob(share_path .. '/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration',
    share_path .. '/mason/packages/jdtls/config_linux',
    '-data',
    workspace_dir,
  },
  root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

  settings = {
    java = {
      signatureHelp = { enabled = true },
      extendedClientCapabilities = extendedClientCapabilities,
      maven = {
        downloadSources = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = 'all', -- literals, all, none
        },
      },
      format = {
        enabled = false,
      },
      saveActions = {
        organizeImports = true,
      },
      completion = {
        favoriteStaticMembers = {
          'io.crate.testing.Asserts.assertThat',
          'org.assertj.core.api.Assertions.assertThat',
          'org.assertj.core.api.Assertions.assertThatThrownBy',
          'org.assertj.core.api.Assertions.assertThatExceptionOfType',
          'org.assertj.core.api.Assertions.catchThrowable',
          'org.hamcrest.MatcherAssert.assertThat',
          'org.hamcrest.Matchers.*',
          'org.hamcrest.CoreMatchers.*',
          'org.junit.jupiter.api.Assertions.*',
          'java.util.Objects.requireNonNull',
          'java.util.Objects.requireNonNullElse',
          'org.mockito.Mockito.*',
        },
        filteredTypes = {
          'com.sun.*',
          'io.micrometer.shaded.*',
          'java.awt.*',
          'jdk.*',
          'sun.*',
        },
      },
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
        hashCodeEquals = {
          useJava7Objects = true,
        },
        useBlocks = true,
      },
    },
  },

  init_options = {
    bundles = get_bundles(),
  },
}
local function test_with_profile(test_fn)
  return function()
    local choices = {
      'cpu,alloc=2m,lock=10ms',
      'cpu',
      'alloc',
      'wall',
      'context-switches',
      'cycles',
      'instructions',
      'cache-misses',
    }
    local select_opts = {
      format_item = tostring,
    }
    vim.ui.select(choices, select_opts, function(choice)
      if not choice then
        return
      end
      local async_profiler_so = home .. '/apps/async-profiler/lib/libasyncProfiler.so'
      local event = 'event=' .. choice
      local vmArgs = '-ea -agentpath:' .. async_profiler_so .. '=start,'
      vmArgs = vmArgs .. event .. ',file=/tmp/profile.jfr'
      test_fn {
        config_overrides = {
          vmArgs = vmArgs,
          noDebug = true,
        },
        after_test = function()
          vim.fn.system 'jfr2flame /tmp/profile.jfr /tmp/profile.html'
          vim.fn.system 'firefox /tmp/profile.html'
        end,
      }
    end)
  end
end

config.on_attach = function(client, bufnr)
  local function with_compile(fn)
    return function()
      if vim.bo.modified then
        vim.cmd 'w'
      end
      client.request_sync('java/buildWorkspace', false, 5000, bufnr)
      fn()
    end
  end

  vim.api.nvim_buf_create_user_command(bufnr, 'A', function()
    require('jdtls.tests').goto_subjects()
  end, {})

  local triggers = vim.tbl_get(client.server_capabilities, 'completionProvider', 'triggerCharacters')

  if triggers then
    for _, char in ipairs { 'a', 'e', 'i', 'o', 'u' } do
      if not vim.tbl_contains(triggers, char) then
        table.insert(triggers, char)
      end
    end
  end
  local map = function(mode, keys, func, desc)
    vim.keymap.set(mode, keys, func, { silent = true, buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  map(
    'n',
    '<F5>',
    with_compile(function()
      local main_config_opts = {
        verbose = false,
        on_ready = require('dap').continue,
      }
      require('jdtls.dap').setup_dap_main_class_configs(main_config_opts)
    end),
    'Run'
  )
  map('n', '<A-o>', jdtls.organize_imports, '[O]rganize imports')
  map('n', '<leader>df', with_compile(jdtls.test_class), 'Run test class')
  map('n', '<leader>dl', with_compile(require('dap').run_last), 'Run last')
  map('n', '<leader>dF', with_compile(test_with_profile(jdtls.test_class)), 'Run test class with profiler')
  map(
    'n',
    '<leader>dn',
    with_compile(function()
      jdtls.test_nearest_method {
        config_overrides = {
          stepFilters = {
            skipClasses = { '$JDK', 'junit.*' },
            skipSynthetics = true,
          },
        },
      }
    end),
    'Run nearest test method'
  )
  map('n', '<leader>dN', with_compile(test_with_profile(jdtls.test_nearest_method)), 'Run nearest test with profiler')

  map('n', 'crv', jdtls.extract_variable_all, 'Extract all variables')
  map('v', 'crv', [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]], 'Extract variable all')
  map('v', 'crm', [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], 'Extract method')
  map('n', 'crc', jdtls.extract_constant, 'Extract constant')
  map('n', '<leader>dp', function()
    local dap = require 'dap'
    if dap.session() then
      local widgets = require 'dap.ui.widgets'
      widgets.centered_float(widgets.scopes)
    else
      client.request_sync('java/buildWorkspace', false, 5000, bufnr)
      require('jdtls.dap').pick_test()
    end
  end, 'Pick test')
end
require('jdtls').start_or_attach(config)
