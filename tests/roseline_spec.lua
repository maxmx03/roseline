local tohex = function(decimal)
  return string.format('#%06x', decimal)
end

describe('roseline', function()
  setup(function()
    vim.opt.laststatus = 3
  end)

  test('rose-line theme', function()
    require('roseline').setup {
      theme = 'rose-pine',
    }
    local output = vim.api.nvim_get_hl(0, { name = 'StNormal' })
    local foreground = tohex(output.fg)
    local expected = require 'roseline.themes.rose-pine'
    assert.equal(expected.normal, foreground)
  end)

  test('dracula theme', function()
    require('roseline').setup {
      theme = 'dracula',
    }

    local output = vim.api.nvim_get_hl(0, { name = 'StNormal' })
    local foreground = tohex(output.fg)
    local expected = require 'roseline.themes.dracula'
    assert.equal(expected.normal:lower(), foreground)
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
