return {
  {
    "echasnovski/mini.bufremove",
    version = false,
    keys = {
      { "<leader>bd", function() _G.SafeBufDelete(false) end, desc = "Delete buffer" },
      { "<leader>bD", function() _G.SafeBufDelete(true) end,  desc = "Delete buffer (force)" },
    },
    config = function()
      local MBR = require("mini.bufremove")

      local function first_normal_win()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local b = vim.api.nvim_win_get_buf(win)
          if vim.bo[b].filetype ~= "NvimTree" then
            return win
          end
        end
        return nil
      end

      local function next_listed_buf(exclude)
        local bufs = vim.tbl_filter(function(b)
          return vim.api.nvim_buf_is_loaded(b)
             and vim.bo[b].buflisted
             and vim.bo[b].filetype ~= "NvimTree"
             and b ~= exclude
        end, vim.api.nvim_list_bufs())
        table.sort(bufs)
        return bufs[1]
      end

      _G.SafeBufDelete = function(force)
        if vim.bo.filetype == "NvimTree" then
          local win = first_normal_win()
          if win then vim.api.nvim_set_current_win(win) else vim.cmd("enew") end
        end

        local target = vim.api.nvim_get_current_buf()
        if vim.bo[target].filetype == "NvimTree" then return end

        local nextb = next_listed_buf(target)
        if nextb then
          vim.api.nvim_set_current_buf(nextb)
        else
          vim.cmd("enew")
        end

        MBR.delete(target, force)
      end
    end,
  },
}
