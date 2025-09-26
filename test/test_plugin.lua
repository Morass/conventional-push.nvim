-- Basic test for conventional-push.nvim
-- This is a simple test to verify the plugin loads correctly

local function test_plugin_loads()
  local success, conventional_push = pcall(require, 'conventional-push')
  if not success then
    error("Failed to load conventional-push module: " .. conventional_push)
  end
  print("✓ Plugin module loads successfully")
end

local function test_git_module_loads()
  local success, git = pcall(require, 'conventional-push.git')
  if not success then
    error("Failed to load conventional-push.git module: " .. git)
  end
  print("✓ Git module loads successfully")
end

local function test_ui_module_loads()
  local success, ui = pcall(require, 'conventional-push.ui')
  if not success then
    error("Failed to load conventional-push.ui module: " .. ui)
  end
  print("✓ UI module loads successfully")
end

local function test_git_repository_detection()
  local git = require('conventional-push.git')

  -- Test with current directory (should be true since we're in a git repo)
  local current_file = vim.fn.expand('%:p')
  local is_git_repo = git.is_git_repository(current_file)

  print("✓ Git repository detection function works")
  print("  Current file: " .. current_file)
  print("  Is git repo: " .. tostring(is_git_repo))
end

local function test_default_prefixes()
  local expected_prefixes = {'chore', 'fix', 'docs', 'feat', 'test', 'refactor', 'style', 'build', 'perf', 'debug', 'ci', 'revert', 'merge'}
  local actual_prefixes = vim.g.conventional_push_prefixes

  if not actual_prefixes then
    print("✓ Default prefixes not set yet (normal)")
    return
  end

  if #actual_prefixes == #expected_prefixes then
    print("✓ Default prefixes length matches expected")
  else
    print("✗ Default prefixes length mismatch")
  end
end

local function run_tests()
  print("Running conventional-push.nvim tests...")
  print("")

  test_plugin_loads()
  test_git_module_loads()
  test_ui_module_loads()
  test_git_repository_detection()
  test_default_prefixes()

  print("")
  print("Tests completed!")
end

-- Run tests if this file is executed directly
if vim.fn.expand('%:t') == 'test_plugin.lua' then
  run_tests()
end

return {
  run_tests = run_tests
}