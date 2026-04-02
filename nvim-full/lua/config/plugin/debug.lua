local dap_config = {
  js_based_languages = {
    'typescript',
    'javascript',
  },
  ensure_installed = {
    -- 'kotlin',
    'javatest',
    'javadbg',
    'js-debug-adapter',
    'codelldb',
  },
  adapters = {
    -- ['pwa-node'] = {
    --   type = 'server',
    --   host = '127.0.0.1',
    --   port = 8123,
    --   executable = {
    --     command = 'js-debug-adapter',
    --   },
    -- },
  },
  configurations = {
    java = {
      {
        javaExec = 'java',
        request = 'launch',
        type = 'java',
      },
      {
        type = 'java',
        request = 'attach',
        name = 'Debug (Attach) - Remote',
        hostName = '127.0.0.1',
        port = 5005,
      },
    },
  },
}
for _, language in ipairs(dap_config.js_based_languages) do
  dap_config.configurations[language] = {
    -- Debug single nodejs files
    {
      type = 'pwa-node',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
    },
    -- Debug nodejs processes (make sure to add --inspect when you run the process)
    {
      type = 'pwa-node',
      request = 'attach',
      name = 'Attach',
      processId = require('dap.utils').pick_process,
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
    },
    -- Debug web applications (client side)
    {
      type = 'pwa-chrome',
      request = 'launch',
      name = 'Launch & Debug Chrome',
      url = function()
        local co = coroutine.running()
        return coroutine.create(function()
          vim.ui.input({
            prompt = 'Enter URL: ',
            default = 'http://localhost:3000',
          }, function(url)
            if url == nil or url == '' then
              return
            else
              coroutine.resume(co, url)
            end
          end)
        end)
      end,
      webRoot = vim.fn.getcwd(),
      protocol = 'inspector',
      sourceMaps = true,
      userDataDir = false,
    },
    -- Divider for the launch.json derived configs
    {
      name = '----- ↓ launch.json configs ↓ -----',
      type = '',
      request = 'launch',
    },
  }
end
return dap_config
