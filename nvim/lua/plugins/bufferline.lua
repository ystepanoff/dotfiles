return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    vim.opt.termguicolors = true
    vim.opt.showtabline = 2

    require("bufferline").setup({
      options = {
        diagnostics = false,
        separator_style = "slant",
        show_buffer_close_icons = false,
        show_close_icon = false,
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    })

    local function safe_buf_delete()
      local wins = vim.api.nvim_list_wins()
      local tree_win = nil
      for _, w in ipairs(wins) do
        local b = vim.api.nvim_win_get_buf(w)
        if vim.bo[b].filetype == 'NvimTree' then
          tree_win = w
          break
        end
      end

      if tree_win and #wins == 2 then
        vim.cmd('wincmd p')
      end

      local ok, bd = pcall(require, 'bufdelete')
      if ok then
        bd.bufdelete(0, true)
      else
        vim.cmd('bdelete')
      end
    end

    local map = vim.keymap.set
    map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
    map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
    -- map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })
    for i = 1, 9 do
      map("n", ("<leader>%d"):format(i), ("<cmd>BufferLineGoToBuffer %d<CR>"):format(i),
        { desc = ("Go to buffer %d"):format(i) })
    end
  end,
}
