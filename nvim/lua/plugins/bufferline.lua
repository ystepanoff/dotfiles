return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    vim.opt.termguicolors = true
    vim.opt.showtabline = 2

    require("bufferline").setup({
      options = {
        diagnostics = "nvim_lsp",
        separator_style = "slant",
        show_buffer_close_icons = false,
        show_close_icon = false,
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    })

    local map = vim.keymap.set
    map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
    map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
    map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })
    for i = 1, 9 do
      map("n", ("<leader>%d"):format(i), ("<cmd>BufferLineGoToBuffer %d<CR>"):format(i),
        { desc = ("Go to buffer %d"):format(i) })
    end
  end,
}
