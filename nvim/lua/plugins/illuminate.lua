return {
  {
    'RRethy/vim-illuminate',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { 'lsp' },
      },
    },
    config = function(_, opts)
      require('illuminate').configure(opts)

      vim.keymap.set('n', ']]', function()
        require('illuminate').goto_next_reference(false)
      end, { desc = 'Next reference' })
      vim.keymap.set('n', '[[', function()
        require('illuminate').goto_prev_reference(false)
      end, { desc = 'Previous reference' })
    end,
  },
}
