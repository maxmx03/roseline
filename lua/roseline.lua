vim.opt.statusline = "%!v:lua.require('roseline').setup()"

local M = {}

local icons = {
  vim = '',
  git = {
    head = '',
    added = '',
    changed = '',
    removed = '',
  },
  diagnostic = {
    Error = '',
    Warning = '',
    Information = '',
    Question = '',
    Hint = '󰌶',
    Debug = '',
    Ok = '󰧱',
  },
  os = {
    Linux = '',
    microsoft = '',
    Darwin = '',
  },
  default = { left = '', right = '' },
  block = { left = '█', right = '█' },
  round = { left = '', right = '' },
}

---@param item string
---@param group_name string
---@return string
local function color(item, group_name)
  return '%#' .. group_name .. '#' .. item .. '%*'
end

local function set_highlight()
  local group = 'St'
  local ok, colors = pcall(require, 'rose-pine.palette')

  if not ok then
    return
  end

  local hl = vim.api.nvim_set_hl
  local modes_colors = {
    Normal = colors.foam,
    Insert = colors.rose,
    Visual = colors.iris,
    Replace = colors.love,
    Command = colors.gold,
  }

  for group_name, group_color in pairs(modes_colors) do
    hl(0, group .. group_name, { fg = group_color, bg = colors.base })
  end

  for group_name, group_color in pairs(modes_colors) do
    group_name = group_name .. 'Reverse'
    hl(0, group .. group_name, { fg = group_color, reverse = true })
  end

  hl(0, group .. 'Neovim', { fg = colors.foam, reverse = true })
  hl(0, group .. 'GitHead', { fg = colors.iris, bg = colors.base })
  hl(0, group .. 'GitAdded', { fg = colors.foam, bg = colors.base })
  hl(0, group .. 'GitRemoved', { fg = colors.love, bg = colors.base })
  hl(0, group .. 'GitChanged', { fg = colors.rose, bg = colors.base })
  hl(0, group .. 'DiagnosticError', { fg = colors.love, reverse = true })
  hl(0, group .. 'DiagnosticWarn', { fg = colors.gold, reverse = true })
  hl(0, group .. 'DiagnosticHint', { fg = colors.iris, reverse = true })
  hl(0, group .. 'DiagnosticInfo', { fg = colors.foam, reverse = true })
  hl(0, group .. 'DiagnosticErrorLspClient', { fg = colors.love, bg = colors.base })
  hl(0, group .. 'DiagnosticWarnLspClient', { fg = colors.gold, bg = colors.base })
  hl(0, group .. 'DiagnosticHintLspClient', { fg = colors.iris, bg = colors.base })
  hl(0, group .. 'DiagnosticInfoLspClient', { fg = colors.foam, bg = colors.base })
  hl(0, group .. 'Lsp', { fg = colors.foam, bg = colors.base })
  hl(0, group .. 'LspReverse', { fg = colors.foam, reverse = true })
  hl(0, group .. 'Info', { fg = colors.foam, bg = colors.base })
  hl(0, group .. 'InfoReverse', { fg = colors.foam, reverse = true })
end

--- mode
---@return string
local function layout_a()
  local modes = {
    ['n'] = { 'NORMAL', 'Normal' },
    ['no'] = { 'NORMAL (no)', 'Normal' },
    ['nov'] = { 'NORMAL (nov)', 'Normal' },
    ['noV'] = { 'NORMAL (noV)', 'Normal' },
    ['noCTRL-V'] = { 'NORMAL', 'Normal' },
    ['niI'] = { 'NORMAL i', 'Normal' },
    ['niR'] = { 'NORMAL r', 'Normal' },
    ['niV'] = { 'NORMAL v', 'Normal' },
    ['nt'] = { 'NTERMINAL', 'Normal' },
    ['ntT'] = { 'NTERMINAL (ntT)', 'Normal' },
    ['v'] = { 'VISUAL', 'Visual' },
    ['vs'] = { 'V-CHAR (Ctrl O)', 'Visual' },
    ['Vs'] = { 'V-LINE', 'Visual' },
    ['V'] = { 'V-LINE', 'Visual' },
    [''] = { 'V-BLOCK', 'Visual' },
    ['i'] = { 'INSERT', 'Insert' },
    ['ic'] = { 'INSERT (completion)', 'Insert' },
    ['ix'] = { 'INSERT completion', 'Insert' },
    ['t'] = { 'TERMINAL', 'Insert' },
    ['R'] = { 'REPLACE', 'Replace' },
    ['Rc'] = { 'REPLACE (Rc)', 'Replace' },
    ['Rx'] = { 'REPLACEa (Rx)', 'Replace' },
    ['Rv'] = { 'V-REPLACE', 'Replace' },
    ['Rvc'] = { 'V-REPLACE (Rvc)', 'Replace' },
    ['Rvx'] = { 'V-REPLACE (Rvx)', 'Replace' },
    ['s'] = { 'SELECT', 'Select' },
    ['S'] = { 'S-LINE', 'Select' },
    [''] = { 'S-BLOCK', 'Select' },
    ['c'] = { 'COMMAND', 'Command' },
    ['cv'] = { 'COMMAND', 'Command' },
    ['ce'] = { 'COMMAND', 'Command' },
    ['r'] = { 'PROMPT', 'Command' },
    ['rm'] = { 'MORE', 'Command' },
    ['r?'] = { 'CONFIRM', 'Command' },
    ['x'] = { 'CONFIRM', 'Command' },
    ['!'] = { 'SHELL', 'Command' },
  }

  local group = 'St'
  local mode_name = modes[vim.fn.mode()][1]
  local mode_group_name = group .. modes[vim.fn.mode()][2]
  local mode = color(mode_name, mode_group_name .. 'Reverse')
  local block = color(icons.block.left, mode_group_name)
  local neovim = color(icons.vim, mode_group_name .. 'Reverse')
  local default_right = color(icons.default.right, mode_group_name)
  return string.format('%s%s%s%s%s', block, neovim, block, mode, default_right)
end

--- git sign
---@return string
local function layout_b()
  if not vim.b.gitsigns_status_dict then
    return ''
  end

  local git = vim.b.gitsigns_status_dict
  local head = ''
  local added = ''
  local changed = ''
  local removed = ''

  local function section(item, icon, group_name)
    local value = ''
    if not item or item == 0 then
      return value
    end
    value = string.format('%s %s', icon, item)
    value = color(value, 'StGit' .. group_name)
    return value
  end

  head = section(git.head, icons.git.head, 'Head')
  added = section(git.added, icons.git.added, 'Added')
  changed = section(git.changed, icons.git.changed, 'Changed')
  removed = section(git.removed, icons.git.removed, 'Removed')

  return string.format('%s %s %s %s', head, added, changed, removed)
end

--- lsp and diagnostic
---@return string
local function layout_d()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients { bufnr = bufnr }
  local client_name = ''
  local default_msg = icons.diagnostic.Ok .. ' No Active Client'

  if not clients or vim.tbl_isempty(clients) then
    return default_msg
  end

  for _, client in pairs(clients) do
    if client.name ~= 'null-ls' then
      client_name = client.name
    end
  end

  if client_name == '' then
    return default_msg
  end

  local errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
  local hints = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT })
  local info = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO })

  local error_msg = (errors and errors > 0) and (icons.diagnostic.Error .. ' ' .. errors) or nil
  local warning_msg = (warnings and warnings > 0) and (icons.diagnostic.Warning .. ' ' .. warnings)
    or nil
  local hint_msg = (hints and hints > 0) and (icons.diagnostic.Hint .. ' ' .. hints) or nil
  local info_msg = (info and info > 0) and (icons.diagnostic.Information .. ' ' .. info) or nil

  ---@param msg string
  ---@param severity string
  ---@return string
  local function diagnostic_message(msg, severity)
    return string.format(
      '%s%s%s %s',
      color(icons.round.left, 'Diagnostic' .. severity),
      color(msg, 'StDiagnostic' .. severity),
      color(icons.block.right, 'Diagnostic' .. severity),
      color(client_name, 'StDiagnostic' .. severity .. 'LspClient')
    )
  end

  if error_msg then
    return diagnostic_message(error_msg, 'Error')
  elseif warning_msg then
    return diagnostic_message(warning_msg, 'Warn')
  elseif hint_msg then
    return diagnostic_message(hint_msg, 'Hint')
  elseif info_msg then
    return diagnostic_message(info_msg, 'Info')
  end

  return string.format(
    '%s%s%s %s',
    color(icons.round.left, 'StLsp'),
    color(icons.diagnostic.Ok, 'StLspReverse'),
    color(icons.block.right, 'StLsp'),
    color(client_name, 'StLsp')
  )
end

local function layout_e()
  return string.format(
    '%s%s%s %s',
    color(icons.round.left, 'StInfo'),
    color(icons.os[vim.loop.os_uname().sysname], 'StInfoReverse'),
    color(icons.block.right, 'StInfo'),
    color('%l:%L', 'StInfo')
  )
end

function M.setup()
  set_highlight()

  local layout = {
    a = layout_a(),
    b = layout_b(),
    c = '',
    d = layout_d(),
    e = layout_e(),
  }

  return string.format('%s %s %%= %s %%= %s %s', layout.a, layout.b, layout.c, layout.d, layout.e)
end

return M
