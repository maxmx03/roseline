local M = {}

M.config = nil

---@param item string
---@param group_name string
---@return string
local function color(item, group_name)
  return '%#' .. group_name .. '#' .. item .. '%*'
end

---@param theme string
local function set_highlight(theme)
  local group = 'St'
  local ok, colors = pcall(require, 'roseline.themes.' .. theme)

  if not ok then
    return
  end

  local hl = vim.api.nvim_set_hl
  local modes_colors = {
    Normal = colors.cyan,
    Insert = colors.pink,
    Visual = colors.purple,
    Replace = colors.red,
    Command = colors.yellow,
  }

  for group_name, group_color in pairs(modes_colors) do
    hl(0, group .. group_name, { fg = group_color, bg = colors.background })
  end

  for group_name, group_color in pairs(modes_colors) do
    hl(0, group .. group_name .. 'Reverse', { fg = group_color, reverse = true })
  end

  hl(0, group .. 'GitHead', { fg = colors.purple, bg = colors.background })
  hl(0, group .. 'GitAdded', { fg = colors.cyan, bg = colors.background })
  hl(0, group .. 'GitRemoved', { fg = colors.red, bg = colors.background })
  hl(0, group .. 'GitChanged', { fg = colors.pink, bg = colors.background })
  hl(0, group .. 'DiagnosticError', { fg = colors.red, reverse = true })
  hl(0, group .. 'DiagnosticWarn', { fg = colors.yellow, reverse = true })
  hl(0, group .. 'DiagnosticHint', { fg = colors.purple, reverse = true })
  hl(0, group .. 'DiagnosticInfo', { fg = colors.cyan, reverse = true })
  hl(0, group .. 'DiagnosticErrorLspClient', { fg = colors.red, bg = colors.background })
  hl(0, group .. 'DiagnosticWarnLspClient', { fg = colors.yellow, bg = colors.background })
  hl(0, group .. 'DiagnosticHintLspClient', { fg = colors.purple, bg = colors.background })
  hl(0, group .. 'DiagnosticInfoLspClient', { fg = colors.cyan, bg = colors.background })
  hl(0, group .. 'Lsp', { fg = colors.cyan, bg = colors.base })
  hl(0, group .. 'LspReverse', { fg = colors.cyan, reverse = true })
  hl(0, group .. 'Info', { fg = colors.cyan, bg = colors.background })
  hl(0, group .. 'InfoReverse', { fg = colors.cyan, reverse = true })
end

--- mode
---@return string
local function section_a()
  local icons = M.config.icons
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
local function section_b()
  local icons = M.config.icons
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
local function section_d()
  local icons = M.config.icons
  local bufnr = vim.api.nvim_get_current_buf()
  local clients

  if vim.fn.has 'nvim-0.10' == 1 then
    clients = vim.lsp.get_clients { bufnr = bufnr }
  else
    ---@diagnostic disable-next-line: deprecated
    clients = vim.lsp.get_active_clients { bufnr = bufnr }
  end

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

local function section_e()
  local icons = M.config.icons
  return string.format(
    '%s%s%s %s',
    color(icons.round.left, 'StInfo'),
    color(icons.os[vim.loop.os_uname().sysname], 'StInfoReverse'),
    color(icons.block.right, 'StInfo'),
    color('%l:%L', 'StInfo')
  )
end

local function default_config()
  local layout = {
    a = section_a,
    b = section_b,
    c = function ()
      return ''
    end,
    d = section_d,
    e = section_e,
  }
  local theme = 'rose-pine'
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

  return {
    layout = layout,
    theme = theme,
    icons = icons,
  }
end

function M.load()
  M.config = M.config or default_config()
  local sections = M.config.layout
  return string.format(
    '%s %s %%= %s %%= %s %s',
    sections.a(),
    sections.b(),
    sections.c(),
    sections.d(),
    sections.e()
  )
end

function M.setup(opts)
  M.config = vim.tbl_extend('force', default_config(), opts or {})
  set_highlight(M.config.theme)
end

return M
