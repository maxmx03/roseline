# Roseline

![screenshot](https://github.com/maxmx03/roseline/assets/50273941/2d6593b7-6e80-4d22-a714-c84b15b325bb)

Minimal statusline

## Requirements

- [lsp](neovim/nvim-lspconfig)
- [gitsign](https://github.com/lewis6991/gitsigns.nvim)

## Setup

### lazy

```lua
return {
 {
    'maxmx03/roseline',
    opts = {},
    dependencies = {
      'rose-pine/neovim',
    }
 }
}
```

## Configuration

To customize the layout, you need to create a function that will return a
string. This string will be the section of your status line.

```lua
require('roseline').setup {
    theme = 'rose-pine',
    layout = {
        a = section_a,
        b = section_b,
        c = section_c,
        d = section_d,
        e = section_e,
    },
    icons = {
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
    },
}
```

## Docs

`h roseline`

## Contribution

Any contributions are welcome; just send a pull request.

### Running Tests

#### Locally

```bash
apt install luarocks
luarocks install luacheck
luarocks install vusted
vusted tests

```

#### Inside a container

```bash
docker compose up
```
