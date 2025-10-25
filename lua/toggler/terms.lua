-- lua/toggler/terms.lua
-- A simple terminal toggler that manages 3 independent terminal instances
local M = {}

-- Configuration
local cfg = {
  height = 12,       -- split height in lines
  border = "rounded" -- for future float layout support
}

-- State for 3 toggleable terminals
local terms = {
  [1] = { buf = nil, win = nil },
  [2] = { buf = nil, win = nil },
  [3] = { buf = nil, win = nil },
  [4] = { buf = nil, win = nil },
  [5] = { buf = nil, win = nil },
}

-- Helper functions
local function buf_valid(b)
  return b and vim.api.nvim_buf_is_valid(b)
end

local function win_valid(w)
  return w and vim.api.nvim_win_is_valid(w)
end

local function apply_term_locals(win)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
end

local function ensure_split(i)
  -- Save current window to restore focus later if needed
  local prev_win = vim.api.nvim_get_current_win()

  -- Open a bottom split and show terms[i].buf
  vim.cmd("botright " .. cfg.height .. "split")
  local win = vim.api.nvim_get_current_win()
  terms[i].win = win

  if not buf_valid(terms[i].buf) then
    -- Create a fresh buffer and start a terminal inside it
    terms[i].buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, terms[i].buf)

    -- Start terminal with shell
    local job_id = vim.fn.termopen(vim.o.shell)
    if job_id <= 0 then
      vim.notify("Failed to start terminal", vim.log.levels.ERROR)
      return
    end

    -- Set buffer name for easier identification
    vim.api.nvim_buf_set_name(terms[i].buf, "Terminal " .. i)
  else
    -- Reuse existing buffer
    vim.api.nvim_win_set_buf(win, terms[i].buf)
  end

  apply_term_locals(win)
  vim.cmd("startinsert")
end

-- Toggle terminal visibility
function M.toggle(i)
  if not i or i < 1 or i > 5 then
    vim.notify("Invalid terminal index: " .. tostring(i), vim.log.levels.ERROR)
    return
  end

  local t = terms[i]

  -- Check if terminal window is currently visible
  if win_valid(t.win) and vim.api.nvim_win_get_buf(t.win) == t.buf then
    -- Terminal is visible -> hide it (keep buffer/job alive)
    vim.api.nvim_win_close(t.win, true)
    t.win = nil
    return
  end

  -- Terminal is not visible -> show it
  ensure_split(i)
end

-- Run a command in a specific terminal (e.g., lazygit)
function M.run(i, cmd)
  if not i or i < 1 or i > 5 then
    vim.notify("Invalid terminal index: " .. tostring(i), vim.log.levels.ERROR)
    return
  end

  if not cmd or cmd == "" then
    vim.notify("No command provided", vim.log.levels.ERROR)
    return
  end

  local t = terms[i]

  -- Ensure terminal is visible
  if not win_valid(t.win) then
    ensure_split(i)
    t = terms[i]
  else
    vim.api.nvim_set_current_win(t.win)
  end

  -- Get the terminal job ID and send the command
  local bufnr = vim.api.nvim_win_get_buf(t.win)
  local job_id = vim.b[bufnr].terminal_job_id

  if job_id then
    vim.fn.chansend(job_id, cmd .. "\n")
    vim.cmd("startinsert")
  else
    vim.notify("Terminal job not found", vim.log.levels.ERROR)
  end
end



-- Autocmd for terminal buffers
local function setup_autocmd()
  vim.api.nvim_exec([[
    augroup TerminalGroup
      autocmd!
      autocmd TermOpen * setlocal winhighlight=Normal:Terminal
    augroup END
  ]], false)
end

-- Apply the terminal background style globally
local function style_terminals()
  vim.cmd('highlight Terminal guibg=#000000') -- sets the terminal background to black
end

-- Expose configuration for customization
M.config = cfg
setup_autocmd()  -- to ensure term settings are applied
style_terminals() -- to ensure the terminal highlight styles are applied

return M
