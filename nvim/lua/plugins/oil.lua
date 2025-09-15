return {
  {
    'stevearc/oil.nvim',
    -- Always run setup explicitly so API is ready before use
    config = function()
      require('oil').setup({
        default_file_explorer = true,
      })

      -- When inside Oil, make <CR> open files in the remembered editor window
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'oil',
        callback = function(args)
          local api = vim.api
          local buf = args.buf
          vim.keymap.set('n', '<CR>', function()
            local oil = require('oil')
            local entry = oil.get_cursor_entry()
            if not entry then return end

            -- Navigate directories inside the sidebar
            if entry.type == 'directory' then
              oil.open()
              return
            end

            -- Choose target editor window
            local target = vim.t.oil_target_win
            if not (target and api.nvim_win_is_valid(target)) then
              -- fallback: any non-oil window in this tab
              for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
                local b = api.nvim_win_get_buf(win)
                if vim.bo[b].filetype ~= 'oil' then target = win; break end
              end
            end

            local dir = oil.get_current_dir() or ''
            local path = dir .. entry.name
            if target then
              api.nvim_set_current_win(target)
              vim.cmd('edit ' .. vim.fn.fnameescape(path))
            else
              -- fallback: open in place
              oil.open()
            end
          end, { buffer = buf, desc = 'Open in editor window' })
        end,
      })
    end,

    keys = {
      {
        '<leader>e',
        function()
          local api = vim.api
          local prevwin = api.nvim_get_current_win()  -- remember editor window

          -- helper to detect Oil windows
          local function win_is_oil(win)
            if not (win and api.nvim_win_is_valid(win)) then return false end
            local buf = api.nvim_win_get_buf(win)
            return api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'oil'
          end

          -- If an Oil window exists in this tab, close it (toggle)
          for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
            if win_is_oil(win) then
              api.nvim_win_close(win, true)
              if vim.t.oil_sidebar_win == win then
                vim.t.oil_sidebar_win = nil
                vim.t.oil_target_win = nil
              end
              return
            end
          end

          -- Otherwise open new left sidebar via the command (ensures setup ran)
          vim.cmd('vsplit | Oil')
          vim.cmd('wincmd H')            -- move to far left
          vim.cmd('vertical resize 30')  -- fixed width

          local oilwin = api.nvim_get_current_win()
          vim.t.oil_sidebar_win = oilwin
          vim.t.oil_target_win = prevwin

          -- cosmetics
          local buf = api.nvim_win_get_buf(oilwin)
          vim.wo[oilwin].number = false
          vim.wo[oilwin].relativenumber = false
          vim.wo[oilwin].winfixwidth = true

          -- clear remembered window if sidebar closes
          vim.api.nvim_create_autocmd({ 'BufWinLeave', 'BufWipeout' }, {
            buffer = buf,
            callback = function()
              if vim.t.oil_sidebar_win == oilwin then
                vim.t.oil_sidebar_win = nil
                vim.t.oil_target_win = nil
              end
            end,
          })
        end,
        desc = 'Toggle Oil sidebar',
      },
    },

    -- Optional: also lazy-load on the :Oil command
    cmd = { 'Oil' },
  },
}
