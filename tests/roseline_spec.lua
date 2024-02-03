local tohex = function(decimal)
  return string.format('#%06x', decimal)
end

describe('roseline', function()
  setup(function()
    vim.opt.laststatus = 3
    require('roseline').setup()
  end)

  test('default theme', function()
    local output = vim.api.nvim_get_hl(0, { name = 'StNormal' })
    local foreground = tohex(output.fg)
    local expected = require 'roseline.themes.rose-pine'
    assert.equal(expected.cyan, foreground)
  end)

  test('user custom icon', function()
    require('roseline').setup {
      icons = {
        vim = '',
      },
    }
    local custom_icon = require('roseline').config.icons.vim
    local expect = ''

    assert.equal(expect, custom_icon)
  end)
end)
