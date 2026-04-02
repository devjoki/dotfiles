local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Helper function to get package name from file path
local function get_package_name()
  local filepath = vim.fn.expand '%:p'
  local java_src_pattern = '.*/src/main/java/(.+)/.+%.java$'
  local java_test_pattern = '.*/src/test/java/(.+)/.+%.java$'

  local package = filepath:match(java_src_pattern) or filepath:match(java_test_pattern)
  if package then
    return package:gsub('/', '.')
  end
  return 'com.example'
end

-- Helper function to get class name from filename
local function get_class_name()
  return vim.fn.expand '%:t:r'
end

return {
  -- Public class
  s('class', {
    t { 'package ' },
    f(get_package_name),
    t { ';', '', '' },
    t { 'public class ' },
    f(get_class_name),
    t { ' {', '    ' },
    i(1, '// TODO: Implement'),
    t { '', '}' },
  }),

  -- Interface
  s('interface', {
    t { 'package ' },
    f(get_package_name),
    t { ';', '', '' },
    t { 'public interface ' },
    f(get_class_name),
    t { ' {', '    ' },
    i(1, '// Define methods'),
    t { '', '}' },
  }),

  -- Abstract class
  s('abstract', {
    t { 'package ' },
    f(get_package_name),
    t { ';', '', '' },
    t { 'public abstract class ' },
    f(get_class_name),
    t { ' {', '    ' },
    i(1, '// TODO: Implement'),
    t { '', '}' },
  }),

  -- Enum
  s('enum', {
    t { 'package ' },
    f(get_package_name),
    t { ';', '', '' },
    t { 'public enum ' },
    f(get_class_name),
    t { ' {', '    ' },
    i(1, 'VALUE1, VALUE2'),
    t { '', '}' },
  }),

  -- Record (Java 14+)
  s('record', {
    t { 'package ' },
    f(get_package_name),
    t { ';', '', '' },
    t { 'public record ' },
    f(get_class_name),
    t { '(' },
    i(1, 'String field'),
    t { ') {', '    ' },
    i(2, '// Optional: Add custom methods'),
    t { '', '}' },
  }),

  -- JUnit test class
  s('test', {
    t { 'package ' },
    f(get_package_name),
    t { ';', '', '' },
    t { 'import org.junit.jupiter.api.Test;', 'import static org.junit.jupiter.api.Assertions.*;', '', '' },
    t { 'class ' },
    f(get_class_name),
    t { ' {', '', '    @Test', '    void ' },
    i(1, 'testMethod'),
    t { '() {', '        ' },
    i(2, '// TODO: Write test'),
    t { '', '    }', '}' },
  }),

  -- Main method
  s('main', {
    t { 'public static void main(String[] args) {', '    ' },
    i(1, '// TODO: Implement'),
    t { '', '}' },
  }),
}
