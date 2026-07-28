local ensure_installed = {
  'lua','python','typescript','tsx','javascript','json',
  'yaml','toml','bash','markdown','markdown_inline','go','rust',
  'html','css','vim','vimdoc','query','regex','dockerfile','gitignore',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- `main` is the only branch supporting Neovim 0.12; `master` is 0.10/0.11 only.
    branch = 'main',
    -- This plugin does not support lazy-loading.
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup()

      local ts = require('nvim-treesitter')
      local installed = ts.get_installed('parsers')
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure_installed)
      if #missing > 0 then
        ts.install(missing)
      end

      -- Highlighting, indentation and folding are opt-in per filetype on `main`.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('ts_attach', { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang or not vim.tbl_contains(ts.get_installed('parsers'), lang) then
            return
          end
          if not pcall(vim.treesitter.start, ev.buf, lang) then
            return
          end
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = {
          lookahead = true,
          selection_modes = {
            ['@function.outer'] = 'V',
            ['@class.outer'] = 'V',
            ['@parameter.outer'] = 'v',
          },
        },
        move = { set_jumps = true },
      })

      local select = require('nvim-treesitter-textobjects.select')
      for lhs, capture in pairs({
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
      }) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(capture, 'textobjects')
        end, { desc = 'Select ' .. capture })
      end

      local move = require('nvim-treesitter-textobjects.move')
      local moves = {
        goto_next_start     = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
        goto_next_end       = { [']M'] = '@function.outer', [']['] = '@class.outer' },
        goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
        goto_previous_end   = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
      }
      for fn, maps in pairs(moves) do
        for lhs, capture in pairs(maps) do
          vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
            move[fn](capture, 'textobjects')
          end, { desc = fn .. ' ' .. capture })
        end
      end
    end,
  },
}
