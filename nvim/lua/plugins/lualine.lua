return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'SmiteshP/nvim-navic', 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'catppuccin',
        globalstatus = true,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        disabled_filetypes = { statusline = { 'dashboard', 'alpha' } },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', { 'diagnostics', sources = { 'nvim_diagnostic' } } },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = {
          {
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then return '' end
              local names = {}
              for _, c in ipairs(clients) do table.insert(names, c.name) end
              return ' ' .. table.concat(names, ',')
            end,
          },
          'encoding', 'fileformat', 'filetype',
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
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
