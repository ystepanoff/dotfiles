return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- or "macchiato", "frappe", "latte"
        integrations = {
          nvimtree = true,
          bufferline = true,
          treesitter = true,
          mason = true,
          which_key = true,
          telescope = true,
          cmp = true,
          gitsigns = true,
        },
      })
      vim.cmd.colorscheme('catppuccin')
    end,
  },
}
