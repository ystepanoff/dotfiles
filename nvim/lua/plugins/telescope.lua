return {
  {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      telescope.setup({
        defaults = {
          path_display = { 'truncate' },
          file_ignore_patterns = {
            '%.git/', 'node_modules/', '%.venv/', '__pycache__/',
            'dist/', 'build/', 'target/', '%.next/', '%.cache/',
          },
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
              ['<esc>'] = actions.close,
            },
          },
        },
        pickers = {
          find_files = { hidden = true },
          live_grep  = { additional_args = function() return { '--hidden' } end },
          buffers    = { sort_lastused = true, ignore_current_buffer = true },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
        },
      })
      pcall(telescope.load_extension, 'fzf')

      local b = require('telescope.builtin')
      local map = vim.keymap.set
      map('n', '<leader>ff', b.find_files,   { desc = 'Find files' })
      map('n', '<leader>fg', b.live_grep,    { desc = 'Live grep' })
      map('n', '<leader>fb', b.buffers,      { desc = 'Buffers' })
      map('n', '<leader>fh', b.help_tags,    { desc = 'Help tags' })
      map('n', '<leader>fr', b.oldfiles,     { desc = 'Recent files' })
      map('n', '<leader>fc', b.commands,     { desc = 'Commands' })
      map('n', '<leader>fk', b.keymaps,      { desc = 'Keymaps' })
      map('n', '<leader>fd', b.diagnostics,  { desc = 'Diagnostics' })
      map('n', '<leader>fs', b.grep_string,  { desc = 'Grep string under cursor' })
      map('n', '<leader>f/', b.current_buffer_fuzzy_find, { desc = 'Fuzzy find in buffer' })
      map('n', '<leader>fR', b.resume,       { desc = 'Resume last picker' })
    end,
  },
}
