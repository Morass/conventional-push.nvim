local M = {}
local ui = require('conventional-push.ui')
local git = require('conventional-push.git')

M.setup = function(opts)
  opts = opts or {}
  if opts.prefixes then
    vim.g.conventional_push_prefixes = opts.prefixes
  end
end

M.start = function()
  local current_file = vim.fn.expand('%:p')

  if not git.is_git_repository(current_file) then
    vim.api.nvim_err_writeln("File " .. current_file .. " is not in a git repository")
    return
  end

  ui.start()
end

return M