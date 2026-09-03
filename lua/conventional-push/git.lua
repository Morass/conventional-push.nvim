local M = {}

-- Run git as an argv list. Neovim executes a list without a shell, so paths
-- and commit messages containing quotes, backticks, $ or spaces are passed
-- through literally instead of being re-parsed by sh.
--
-- The exit code must come from vim.v.shell_error: io.popen's close() returns
-- plain `true` under LuaJIT no matter how the command exited, so the previous
-- implementation could not see a failure at all.
local function git(args)
  local out = vim.fn.system(args)
  return vim.v.shell_error == 0, out or ""
end

M.is_git_repository = function(file_path)
  local dir = file_path
  if vim.fn.isdirectory(file_path) == 0 then
    dir = vim.fn.fnamemodify(file_path, ':h')
  end
  if dir == nil or dir == "" then
    dir = vim.fn.getcwd()
  end

  local ok, out = git({ 'git', '-C', dir, 'rev-parse', '--is-inside-work-tree' })
  return ok and vim.trim(out) == "true"
end

M.get_repository_root = function()
  local ok, out = git({ 'git', 'rev-parse', '--show-toplevel' })
  if not ok then
    return nil
  end
  out = vim.trim(out)
  if out == "" then
    return nil
  end
  return out
end

-- Parse `git status --porcelain -z`.
--
-- -z is what makes this correct: paths are NUL-terminated and emitted raw, so
-- a file with a space, a quote or a non-ASCII name arrives intact instead of
-- C-quoted. Renames and copies emit the new path followed by a second record
-- holding the old path; the old one is consumed and dropped, since the new
-- path is what gets staged.
--
-- vim.fn.system() replaces NUL in command output with SOH (0x01), per
-- :help system(), so the record separator to split on here is \1 and not \0.
M.get_changed_files = function()
  local ok, out = git({ 'git', 'status', '--porcelain', '-z' })
  if not ok or out == "" then
    return {}
  end

  local records = {}
  for record in out:gmatch("([^%z\1]+)") do
    table.insert(records, record)
  end

  local files = {}
  local i = 1
  while i <= #records do
    local record = records[i]
    local status = record:sub(1, 2)
    local path = record:sub(4)

    -- A rename or copy spends the following record on its origin path.
    if status:sub(1, 1) == "R" or status:sub(1, 1) == "C"
        or status:sub(2, 2) == "R" or status:sub(2, 2) == "C" then
      i = i + 1
    end

    if path ~= "" then
      table.insert(files, {
        status = status,
        path = path,
        selected = false
      })
    end
    i = i + 1
  end

  return files
end

M.add_files = function(file_paths)
  local repo_root = M.get_repository_root()
  if not repo_root then
    return false, "Not in a git repository"
  end

  if #file_paths == 0 then
    return false, "No files selected"
  end

  -- `--` stops a path that looks like an option from being read as one.
  local args = { 'git', '-C', repo_root, 'add', '--' }
  for _, file_path in ipairs(file_paths) do
    table.insert(args, file_path)
  end

  local ok, out = git(args)
  if not ok then
    return false, vim.trim(out)
  end
  return true, nil
end

M.commit = function(message)
  local ok, out = git({ 'git', 'commit', '-m', message })
  return ok, out
end

M.push = function()
  local ok, out = git({ 'git', 'push' })
  if ok then
    return true, out
  end

  -- No upstream yet: retry once, setting it to the current branch.
  local branch_ok, branch = git({ 'git', 'rev-parse', '--abbrev-ref', 'HEAD' })
  if not branch_ok then
    return false, out
  end
  branch = vim.trim(branch)
  if branch == "" or branch == "HEAD" then
    return false, out
  end

  local retry_ok, retry_out = git({ 'git', 'push', '--set-upstream', 'origin', branch })
  if retry_ok then
    return true, retry_out
  end
  return false, out .. retry_out
end

return M
