local M = {}

M.is_git_repository = function(file_path)
  local dir = file_path
  if vim.fn.isdirectory(file_path) == 0 then
    dir = vim.fn.fnamemodify(file_path, ':h')
  end

  local handle = io.popen('cd "' .. dir .. '" && git rev-parse --is-inside-work-tree 2>/dev/null')
  local result = handle:read("*a")
  handle:close()

  return vim.trim(result) == "true"
end

M.get_repository_root = function()
  local handle = io.popen('git rev-parse --show-toplevel 2>/dev/null')
  local result = handle:read("*a")
  handle:close()

  if result and result ~= "" then
    return vim.trim(result)
  end
  return nil
end

M.get_changed_files = function()
  local handle = io.popen('git status --porcelain 2>/dev/null')
  local result = handle:read("*a")
  handle:close()

  local files = {}
  if result and result ~= "" then
    for line in result:gmatch("[^\r\n]+") do
      local status = line:sub(1, 2)
      local file = line:sub(4)
      file = file:gsub('^"', ''):gsub('"$', '')
      table.insert(files, {
        status = status,
        path = file,
        selected = false
      })
    end
  end

  return files
end

M.add_files = function(file_paths)
  local repo_root = M.get_repository_root()
  if not repo_root then
    return false, "Not in a git repository"
  end

  for _, file_path in ipairs(file_paths) do
    local full_path = repo_root .. "/" .. file_path
    local handle = io.popen('git add "' .. full_path .. '" 2>&1')
    local result = handle:read("*a")
    local success = handle:close()

    if not success then
      return false, "Failed to add file: " .. file_path .. " - " .. result
    end
  end

  return true, nil
end

M.commit = function(message)
  local handle = io.popen('git commit -m "' .. message:gsub('"', '\\"') .. '" 2>&1')
  local result = handle:read("*a")
  local success = handle:close()

  return success, result
end

M.push = function()
  local handle = io.popen('git push 2>&1 || git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD) 2>&1')
  local result = handle:read("*a")
  local success = handle:close()

  return success, result
end

return M