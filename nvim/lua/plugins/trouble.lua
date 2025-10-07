return {
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    keys = {
      { '<leader>xx', function() require('trouble').toggle() end, desc = 'Diagnostics (Trouble)' },
    },
  },
}
