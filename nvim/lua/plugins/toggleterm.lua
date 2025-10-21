return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",
  opts = {
    direction = "float",
    start_in_insert = true,
    close_on_exit = false,
    persist_mode = true,
    shade_terminals = true,
    float_opts = { border = "single" },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local Terminal = require("toggleterm.terminal").Terminal

    local function focus_non_tree_win()
      local cur = vim.api.nvim_get_current_win()
      local buf = vim.api.nvim_win_get_buf(cur)
      if vim.bo[buf].filetype ~= "NvimTree" then return true end
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local b = vim.api.nvim_win_get_buf(w)
        if vim.bo[b].filetype ~= "NvimTree" and vim.bo[b].buftype == "" then
          vim.api.nvim_set_current_win(w)
          return true
        end
      end
      return false
    end

    local floating_term

    local function toggle_bottom_floating_term()
      if not focus_non_tree_win() then return end

      local win = vim.api.nvim_get_current_win()
      local ww  = vim.api.nvim_win_get_width(win)
      local wh  = vim.api.nvim_win_get_height(win)

      local desired_h = math.max(8, math.min(20, math.floor(wh * 0.35)))

      -- account for rounded border taking 1 col/row each side
      local content_w = math.max(ww - 2, 20)
      local content_h = math.max(desired_h - 2, 6)

      local row = wh - content_h
      local col = 0

      if not floating_term then
        floating_term = Terminal:new({
          direction = "float",
          float_opts = {
            relative = "win",
            anchor   = "NW",
            row      = row,
            col      = col,
            width    = content_w,
            height   = content_h,
            border   = "single",
          },
          on_open = function(t)
            vim.bo[t.bufnr].filetype = "terminal"
            vim.cmd.startinsert()
          end,
        })
      else
        floating_term.float_opts = floating_term.float_opts or {}
        floating_term.float_opts.relative = "win"
        floating_term.float_opts.anchor   = "NW"
        floating_term.float_opts.row      = row
        floating_term.float_opts.col      = col
        floating_term.float_opts.width    = content_w
        floating_term.float_opts.height   = content_h
        floating_term.float_opts.border   = "single"
      end

      floating_term:toggle()
    end

    vim.keymap.set("n", "<leader>t", toggle_bottom_floating_term, { desc = "Toggle bottom terminal (window-local float)" })
  end,
}
