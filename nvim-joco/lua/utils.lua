local Utils = {}

local function input_with_new_line(prompt)
  local input = vim.fn.input(prompt)
  print '\n'
  return input
end

function Utils.reload(module)
  package.loaded[module] = nil
  return require(module)
end
--- print using vim inspect
-- @param target The target object to print
function Utils.print(target, prefix)
  prefix = prefix or ''
  print(prefix .. vim.inspect(target))
  return target
end

-- prints loaded module by name
function Utils.print_module(module_name)
  module_name = module_name or input_with_new_line 'module name: '
  Utils.print(package.loaded[module_name], module_name .. ': ')
end

--- read input executes and prints the result
function Utils.execute_and_print()
  local input = input_with_new_line 'code: '
  local chunk = load('return ' .. input)
  if chunk then
    local success, result = pcall(chunk)
    if not success then
      vim.api.nvim_err_writeln(string.format([[Error while parsing input: '%s']], input))
    else
      Utils.print(result, 'result: ')
    end
  else
    vim.api.nvim_err_writeln(string.format([['%s' is not a valid lua code...]], input))
  end
end

--- Execute a command and load the result into a new buffer
function Utils.load_cmd_result_to_buffer()
  vim.cmd [[:execute 'enew | r ! '.input('Enter command: ')]]
end

--- print using vim inspect
-- @param list the list to search in
-- @param item the item being searched for
function Utils.list_contains(list, item)
  for _, element in ipairs(list) do
    if element == item then
      return true
    end
  end
  return false
end

--- Saves the current buffer as root
--- If the buffer does not belong to a file it prompts for a new filename
function Utils.save_as_root()
  local target_file = vim.fn.expand '%:p'
  if vim.fn.filereadable(target_file) == 0 then
    target_file = vim.fn.input 'File doesnt exists where to save it? '
  end
  local temp_file = vim.fn.tempname()
  vim.cmd(':silent w ' .. temp_file)
  local password = vim.fn.inputsecret 'sudo password: '
  local output =
    vim.fn.systemlist(string.format([[echo %s | sudo -S bash -c 'cat %s | tee %s'  >/dev/null]], vim.fn.shellescape(password), temp_file, target_file))
  if Utils.list_contains(output, 'sudo: 1 incorrect password attempt') then
    vim.api.nvim_err_writeln '\nIncorrect sudo password!'
  end
  vim.cmd ':e!'
end

return Utils
