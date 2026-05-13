return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'windwp/nvim-ts-autotag',
    },
    opts = {
      ensure_installed = {
        'lua','python','typescript','tsx','javascript','json',
        'yaml','toml','bash','markdown','markdown_inline','go','rust',
        'html','css','vim','vimdoc','query','regex','dockerfile','gitignore',
      },
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection    = '<C-space>',
          node_incremental  = '<C-space>',
          scope_incremental = '<C-s>',
          node_decremental  = '<C-backspace>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start     = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
          goto_next_end       = { [']M'] = '@function.outer', [']['] = '@class.outer' },
          goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
          goto_previous_end   = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
      require('nvim-ts-autotag').setup()
    end,
  },
}
