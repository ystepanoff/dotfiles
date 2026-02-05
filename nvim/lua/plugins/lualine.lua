return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'SmiteshP/nvim-navic' },
    opts = {
      options = { theme = 'auto' },
      winbar = {
        lualine_c = {
          {
            function() return require('nvim-navic').get_location() end,
            cond = function() return require('nvim-navic').is_available() end,
          },
        },
      },
      inactive_winbar = {
        lualine_c = { 'filename' },
      },
    },
  },
}
