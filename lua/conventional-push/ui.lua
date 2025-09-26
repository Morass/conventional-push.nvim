local M = {}
local git = require('conventional-push.git')

local state = {
  buf = nil,
  win = nil,
  mode = "file_selection",
  files = {},
  selected_files = {},
  selected_prefix = nil,
  commit_message = "",
  ns_id = nil,
  prefix_length = 0
}

local function create_window()
  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.7)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded'
  }

  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_win_set_option(win, 'cursorline', true)

  vim.cmd('highlight ConventionalPushCursorLine ctermbg=236')
  vim.api.nvim_win_set_option(win, 'winhl', 'CursorLine:ConventionalPushCursorLine')

  return buf, win
end

local function render_file_selection()
  local lines = {
    "",
    "  Navigate with j/k, Select with 'a', Deselect with 'd', Toggle with 't'",
    "  Press Enter to continue, q to quit",
    "",
    "  Select All"
  }

  for _, file in ipairs(state.files) do
    local select_icon = file.selected and "✓" or "✗"

    local status_char = file.status:sub(1, 1)
    local status_symbol

    if status_char == 'A' then
      status_symbol = "+"
    elseif status_char == 'D' then
      status_symbol = "-"
    elseif status_char == 'M' then
      status_symbol = "●"
    elseif status_char == 'R' then
      status_symbol = "↻"
    elseif status_char == 'C' then
      status_symbol = "©"
    elseif status_char == '?' then
      status_symbol = "?"
    else
      status_symbol = "?"
    end

    local line = string.format("  %s %s %s", select_icon, status_symbol, file.path)
    table.insert(lines, line)
  end

  local current_row = vim.api.nvim_win_get_cursor(state.win)[1]

  vim.api.nvim_buf_set_option(state.buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

  vim.api.nvim_set_hl(0, 'ConventionalPushGreen', { ctermfg = 46 })
  vim.api.nvim_set_hl(0, 'ConventionalPushRed', { ctermfg = 196 })
  vim.api.nvim_set_hl(0, 'ConventionalPushYellow', { ctermfg = 226 })
  vim.api.nvim_set_hl(0, 'ConventionalPushGray', { ctermfg = 245 })
  vim.api.nvim_set_hl(0, 'ConventionalPushBlue', { ctermfg = 33 })
  vim.api.nvim_set_hl(0, 'ConventionalPushWhite', { ctermfg = 15 })

  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushGray', 1, 0, -1)
  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushGray', 2, 0, -1)
  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushYellow', 4, 2, -1)

  for i, file in ipairs(state.files) do
    local line_idx = 4 + i
    local select_color = file.selected and 'ConventionalPushGreen' or 'ConventionalPushRed'
    vim.api.nvim_buf_add_highlight(state.buf, -1, select_color, line_idx, 2, 3)

    local status_char = file.status:sub(1, 1)
    local status_color
    if status_char == 'A' then
      status_color = 'ConventionalPushGreen'
    elseif status_char == 'D' then
      status_color = 'ConventionalPushRed'
    elseif status_char == 'M' or status_char == 'R' or status_char == 'C' then
      status_color = 'ConventionalPushYellow'
    else
      status_color = 'ConventionalPushWhite'
    end

    vim.api.nvim_buf_add_highlight(state.buf, -1, status_color, line_idx, 4, 5)
  end

  vim.api.nvim_buf_set_option(state.buf, 'modifiable', false)

  if current_row >= 5 and current_row <= (5 + #state.files) then
    vim.api.nvim_win_set_cursor(state.win, {current_row, 0})
  else
    vim.api.nvim_win_set_cursor(state.win, {5, 0})
  end
end

local function render_confirmation()
  local selected_count = 0
  for _, file in ipairs(state.files) do
    if file.selected then
      selected_count = selected_count + 1
    end
  end

  local file_word = selected_count == 1 and "file" or "files"
  local lines = {
    "",
    "  Confirm you want to commit following " .. selected_count .. " " .. file_word .. ":",
    ""
  }

  for _, file in ipairs(state.files) do
    if file.selected then
      local status_char = file.status:sub(1, 1)
      local status_symbol

      if status_char == 'A' then
        status_symbol = "+"
      elseif status_char == 'D' then
        status_symbol = "-"
      elseif status_char == 'M' then
        status_symbol = "●"
      elseif status_char == 'R' then
        status_symbol = "↻"
      elseif status_char == 'C' then
        status_symbol = "©"
      else
        status_symbol = "?"
      end

      table.insert(lines, "  ✓ " .. status_symbol .. " " .. file.path)
    end
  end

  table.insert(lines, "")
  table.insert(lines, "  Press Enter to continue, q to go back")

  vim.api.nvim_buf_set_option(state.buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

  vim.api.nvim_set_hl(0, 'ConventionalPushGreen', { ctermfg = 46 })
  vim.api.nvim_set_hl(0, 'ConventionalPushRed', { ctermfg = 196 })
  vim.api.nvim_set_hl(0, 'ConventionalPushYellow', { ctermfg = 226 })
  vim.api.nvim_set_hl(0, 'ConventionalPushWhite', { ctermfg = 15 })
  vim.api.nvim_set_hl(0, 'ConventionalPushGray', { ctermfg = 245 })
  vim.api.nvim_set_hl(0, 'ConventionalPushBlue', { ctermfg = 33 })

  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushBlue', 1, 0, -1)

  local line_num = 3
  for _, file in ipairs(state.files) do
    if file.selected then
      vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushGreen', line_num, 2, 3)

      local status_char = file.status:sub(1, 1)
      local status_color
      if status_char == 'A' then
        status_color = 'ConventionalPushGreen'
      elseif status_char == 'D' then
        status_color = 'ConventionalPushRed'
      elseif status_char == 'M' or status_char == 'R' or status_char == 'C' then
        status_color = 'ConventionalPushYellow'
      else
        status_color = 'ConventionalPushWhite'
      end
      vim.api.nvim_buf_add_highlight(state.buf, -1, status_color, line_num, 4, 5)

      line_num = line_num + 1
    end
  end

  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushGray', line_num + 1, 0, -1)

  vim.api.nvim_buf_set_option(state.buf, 'modifiable', false)
end

local function render_prefix_selection()
  local prefixes = vim.g.conventional_push_prefixes or {'chore', 'fix', 'docs', 'feat', 'test', 'refactor', 'style', 'build', 'perf', 'debug', 'ci', 'revert', 'merge'}

  local lines = {
    "",
    "  Select conventional commit prefix:",
    ""
  }

  for _, prefix in ipairs(prefixes) do
    table.insert(lines, "  " .. prefix)
  end

  table.insert(lines, "")
  table.insert(lines, "  Press Enter to select, q to go back")

  vim.api.nvim_buf_set_option(state.buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

  vim.api.nvim_set_hl(0, 'ConventionalPushGray', { ctermfg = 245 })
  vim.api.nvim_set_hl(0, 'ConventionalPushBlue', { ctermfg = 33 })

  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushBlue', 1, 0, -1)
  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushGray', 3 + #prefixes + 1, 0, -1)

  vim.api.nvim_buf_set_option(state.buf, 'modifiable', false)

  vim.api.nvim_win_set_cursor(state.win, {4, 0})
end

local function render_message_input()
  local prefix_text = state.selected_prefix .. ": "
  local lines = {
    "",
    "  Enter commit message:",
    "",
    "  " .. prefix_text,
    "",
    "  Press Enter to commit, Escape to go back"
  }

  vim.api.nvim_buf_set_option(state.buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

  vim.api.nvim_set_hl(0, 'ConventionalPushGray', { ctermfg = 245 })
  vim.api.nvim_set_hl(0, 'ConventionalPushBlue', { ctermfg = 33 })

  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushBlue', 1, 0, -1)
  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushGray', 5, 0, -1)

  state.prefix_length = string.len(prefix_text) + 2

  local prefix_len = state.prefix_length
  vim.api.nvim_win_set_cursor(state.win, {4, prefix_len})
  vim.cmd('startinsert!')
end

local function render_push_confirmation()
  local lines = {
    "",
    "  Push to remote?",
    "",
    "  Yes",
    "  No",
    ""
  }

  vim.api.nvim_buf_set_option(state.buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

  vim.api.nvim_set_hl(0, 'ConventionalPushGreen', { ctermfg = 46 })
  vim.api.nvim_set_hl(0, 'ConventionalPushRed', { ctermfg = 196 })
  vim.api.nvim_set_hl(0, 'ConventionalPushBlue', { ctermfg = 33 })

  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushBlue', 1, 0, -1)
  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushGreen', 3, 2, -1)
  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushRed', 4, 2, -1)

  vim.api.nvim_buf_set_option(state.buf, 'modifiable', false)
  vim.api.nvim_win_set_cursor(state.win, {4, 0})
end

local function render_final_summary(push_result)
  local lines = {
    "",
    "  Summary:",
    "",
    "  Commit created successfully!",
  }

  if push_result then
    if push_result.success then
      table.insert(lines, "  Push completed successfully!")
    else
      table.insert(lines, "  Push failed: " .. (push_result.message or "Unknown error"))
    end
  else
    table.insert(lines, "  (Not pushed)")
  end

  table.insert(lines, "")
  table.insert(lines, "  Press Enter to close")

  vim.api.nvim_buf_set_option(state.buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

  vim.api.nvim_set_hl(0, 'ConventionalPushGray', { ctermfg = 245 })
  vim.api.nvim_set_hl(0, 'ConventionalPushBlue', { ctermfg = 33 })

  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushBlue', 1, 0, -1)

  local last_line = #lines - 1
  vim.api.nvim_buf_add_highlight(state.buf, -1, 'ConventionalPushGray', last_line, 0, -1)

  vim.api.nvim_buf_set_option(state.buf, 'modifiable', false)
end

local function handle_file_selection_action(action)
  local cursor = vim.api.nvim_win_get_cursor(state.win)
  local row = cursor[1]

  if row == 5 then
    if action == 'a' then
      for _, file in ipairs(state.files) do
        file.selected = true
      end
    elseif action == 'd' then
      for _, file in ipairs(state.files) do
        file.selected = false
      end
    elseif action == 't' then
      local all_selected = true
      for _, file in ipairs(state.files) do
        if not file.selected then
          all_selected = false
          break
        end
      end
      for _, file in ipairs(state.files) do
        file.selected = not all_selected
      end
    end
    render_file_selection()
    return
  end

  local file_index = row - 5
  if file_index > 0 and file_index <= #state.files then
    local file = state.files[file_index]
    if action == 'a' then
      file.selected = true
    elseif action == 'd' then
      file.selected = false
    elseif action == 't' then
      file.selected = not file.selected
    end
    render_file_selection()
  end
end

local function handle_file_selection_enter()
  local selected_count = 0
  for _, file in ipairs(state.files) do
    if file.selected then
      selected_count = selected_count + 1
    end
  end

  if selected_count == 0 then
    vim.api.nvim_err_writeln("At least one file must be selected")
    return
  end

  state.mode = "confirmation"
  render_confirmation()
end

local function handle_prefix_selection_enter()
  local cursor = vim.api.nvim_win_get_cursor(state.win)
  local row = cursor[1]
  local prefixes = vim.g.conventional_push_prefixes or {'chore', 'fix', 'docs', 'feat', 'test', 'refactor', 'style', 'build', 'perf', 'debug', 'ci', 'revert', 'merge'}

  local prefix_index = row - 3
  if prefix_index > 0 and prefix_index <= #prefixes then
    state.selected_prefix = prefixes[prefix_index]
    state.mode = "message_input"
    render_message_input()
  end
end

local function handle_message_input()
  local line = vim.api.nvim_buf_get_lines(state.buf, 3, 4, false)[1]
  local prefix_pattern = "^%s*" .. vim.pesc(state.selected_prefix) .. ":%s*"
  local message = line:gsub(prefix_pattern, "")
  message = vim.trim(message)

  if message == "" then
    vim.api.nvim_err_writeln("Commit message cannot be empty")
    return
  end

  vim.cmd('stopinsert')
  vim.api.nvim_buf_set_option(state.buf, 'modifiable', false)

  local file_paths = {}
  for _, file in ipairs(state.files) do
    if file.selected then
      table.insert(file_paths, file.path)
    end
  end

  local add_success, add_error = git.add_files(file_paths)
  if not add_success then
    vim.api.nvim_err_writeln("Failed to add files: " .. add_error)
    return
  end

  local full_message = state.selected_prefix .. ": " .. message
  local commit_success, commit_result = git.commit(full_message)
  if not commit_success then
    vim.api.nvim_err_writeln("Failed to commit: " .. commit_result)
    return
  end

  state.mode = "push_confirmation"
  render_push_confirmation()
end

local function handle_push_confirmation_enter()
  local cursor = vim.api.nvim_win_get_cursor(state.win)
  local row = cursor[1]

  if row == 4 then
    local push_success, push_result = git.push()
    state.mode = "final_summary"
    render_final_summary({ success = push_success, message = push_result })
  elseif row == 5 then
    state.mode = "final_summary"
    render_final_summary(nil)
  end
end

local function setup_keymaps()
  local function map(mode, key, callback)
    vim.api.nvim_buf_set_keymap(state.buf, mode, key, '', {
      noremap = true,
      silent = true,
      callback = callback
    })
  end

  map('n', 'q', function()
    if state.mode == "file_selection" or state.mode == "final_summary" then
      M.close()
    elseif state.mode == "confirmation" then
      state.mode = "file_selection"
      render_file_selection()
    elseif state.mode == "prefix_selection" then
      state.mode = "confirmation"
      render_confirmation()
    end
  end)

  map('n', '<CR>', function()
    if state.mode == "file_selection" then
      handle_file_selection_enter()
    elseif state.mode == "confirmation" then
      state.mode = "prefix_selection"
      render_prefix_selection()
    elseif state.mode == "prefix_selection" then
      handle_prefix_selection_enter()
    elseif state.mode == "push_confirmation" then
      handle_push_confirmation_enter()
    elseif state.mode == "final_summary" then
      M.close()
    end
  end)

  map('n', 'a', function()
    if state.mode == "file_selection" then
      handle_file_selection_action('a')
    end
  end)

  map('n', 'd', function()
    if state.mode == "file_selection" then
      handle_file_selection_action('d')
    end
  end)

  map('n', 't', function()
    if state.mode == "file_selection" then
      handle_file_selection_action('t')
    end
  end)

  map('n', 'j', function()
    if state.mode == "file_selection" then
      local cursor = vim.api.nvim_win_get_cursor(state.win)
      local max_line = 5 + #state.files
      if cursor[1] < max_line then
        vim.api.nvim_win_set_cursor(state.win, {cursor[1] + 1, 0})
      end
    elseif state.mode == "prefix_selection" then
      local cursor = vim.api.nvim_win_get_cursor(state.win)
      local prefixes = vim.g.conventional_push_prefixes or {'chore', 'fix', 'docs', 'feat', 'test', 'refactor', 'style', 'build', 'perf', 'debug', 'ci', 'revert', 'merge'}
      local max_line = 3 + #prefixes
      if cursor[1] < max_line then
        vim.api.nvim_win_set_cursor(state.win, {cursor[1] + 1, 0})
      end
    elseif state.mode == "push_confirmation" then
      local cursor = vim.api.nvim_win_get_cursor(state.win)
      if cursor[1] < 5 then
        vim.api.nvim_win_set_cursor(state.win, {cursor[1] + 1, 0})
      end
    end
  end)

  map('n', 'k', function()
    if state.mode == "file_selection" then
      local cursor = vim.api.nvim_win_get_cursor(state.win)
      if cursor[1] > 5 then
        vim.api.nvim_win_set_cursor(state.win, {cursor[1] - 1, 0})
      end
    elseif state.mode == "prefix_selection" then
      local cursor = vim.api.nvim_win_get_cursor(state.win)
      if cursor[1] > 4 then
        vim.api.nvim_win_set_cursor(state.win, {cursor[1] - 1, 0})
      end
    elseif state.mode == "push_confirmation" then
      local cursor = vim.api.nvim_win_get_cursor(state.win)
      if cursor[1] > 4 then
        vim.api.nvim_win_set_cursor(state.win, {cursor[1] - 1, 0})
      end
    end
  end)

  map('i', '<CR>', function()
    if state.mode == "message_input" then
      handle_message_input()
    end
  end)

  map('i', '<Esc>', function()
    vim.cmd('stopinsert')
    vim.api.nvim_buf_set_option(state.buf, 'modifiable', false)
    state.mode = "prefix_selection"
    render_prefix_selection()
  end)

  map('i', '<BS>', function()
    if state.mode == "message_input" then
      local cursor = vim.api.nvim_win_get_cursor(state.win)
      if cursor[2] <= state.prefix_length then
        return
      end
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<BS>', true, false, true), 'n', false)
  end)

  map('i', '<Left>', function()
    if state.mode == "message_input" then
      local cursor = vim.api.nvim_win_get_cursor(state.win)
      if cursor[2] <= state.prefix_length then
        return
      end
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Left>', true, false, true), 'n', false)
  end)
end

M.start = function()
  state.files = git.get_changed_files()

  if #state.files == 0 then
    local repo_root = git.get_repository_root()
    local repo_name = repo_root and vim.fn.fnamemodify(repo_root, ':t') or "unknown"
    vim.api.nvim_err_writeln("No changed files found in repository: " .. repo_name)
    return
  end

  state.buf, state.win = create_window()
  state.mode = "file_selection"

  if not state.ns_id then
    state.ns_id = vim.api.nvim_create_namespace('conventional-push')
  end

  setup_keymaps()
  render_file_selection()
end

M.close = function()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.buf = nil
  state.win = nil
  state.mode = "file_selection"
  state.files = {}
  state.selected_files = {}
  state.selected_prefix = nil
  state.commit_message = ""
  state.prefix_length = 0
end

return M