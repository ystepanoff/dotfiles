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
          telescope = { enabled = true },
          cmp = true,
          gitsigns = true,
          native_lsp = {
            enabled = true,
            virtual_text = { errors = { 'italic' }, hints = { 'italic' }, warnings = { 'italic' }, information = { 'italic' } },
            underlines   = { errors = { 'underline' }, hints = { 'underline' }, warnings = { 'underline' }, information = { 'underline' } },
            inlay_hints  = { background = true },
          },
          navic = { enabled = true, custom_bg = 'NONE' },
          indent_blankline = { enabled = true, scope_color = '', colored_indent_levels = false },
          illuminate = { enabled = true, lsp = true },
          mini = { enabled = true, indentscope_color = '' },
          aerial = true,
          markdown = true,
          render_markdown = true,
          dap = true,
          dap_ui = true,
          dropbar = { enabled = true },
          flash = true,
          lsp_trouble = true,
          notify = true,
          symbols_outline = true,
        },
      })
      vim.cmd.colorscheme('catppuccin')
    end,
  },
}
