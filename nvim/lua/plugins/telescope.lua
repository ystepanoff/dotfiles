return {
  {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local b = require('telescope.builtin')
      local map = vim.keymap.set
      map('n', '<leader>ff', b.find_files, { desc = 'Find files' })
      map('n', '<leader>fg', b.live_grep,  { desc = 'Live grep' })
      map('n', '<leader>fb', b.buffers,    { desc = 'Buffers' })
      map('n', '<leader>fh', b.help_tags,  { desc = 'Help tags' })
    end,
  },
}
