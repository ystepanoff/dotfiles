return {
  {
    'stevearc/oil.nvim',
    config = function()
      require('oil').setup({
        default_file_explorer = true,
        view_options = { show_parent_dir = true, show_hidden = true },
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'oil',
        callback = function(args)
          local api = vim.api
          local buf = args.buf

          vim.keymap.set('n', '<CR>', function()
            local oil = require('oil')
            local entry = oil.get_cursor_entry()
            if not entry then return end

            if entry.type == 'directory' then
              oil.select({ horizontal = false, vertical = false, split = nil })
              return
            end

            local function win_is_valid_editor(win)
              if not (win and api.nvim_win_is_valid(win)) then return false end
              local b = api.nvim_win_get_buf(win)
              return api.nvim_buf_is_valid(b) and vim.bo[b].filetype ~= 'oil'
            end

            local target = vim.t.oil_target_win
            if not win_is_valid_editor(target) then
              for _, w in ipairs(api.nvim_tabpage_list_wins(0)) do
                if win_is_valid_editor(w) then
                  target = w
                  break
                end
              end
            end

            if not win_is_valid_editor(target) then
              local oilwin = api.nvim_get_current_win()
              vim.cmd('vsplit')
              vim.cmd('wincmd l')
              target = api.nvim_get_current_win()
              vim.t.oil_target_win = target

              if api.nvim_win_is_valid(oilwin) then
                api.nvim_set_current_win(oilwin)
                vim.cmd('vertical resize 30')
                api.nvim_set_current_win(target)
              end
            end

            local dir = oil.get_current_dir() or ''
            local path = dir .. entry.name
            api.nvim_set_current_win(target)
            vim.cmd('edit ' .. vim.fn.fnameescape(path))
          end, { buffer = buf, desc = 'Oil: open file in editor / enter directory' })
        end,
      })
    end,

    keys = {
      {
        '<leader>e',
        function()
          local api = vim.api
          local prevwin = api.nvim_get_current_win()

          local function win_is_oil(win)
            if not (win and api.nvim_win_is_valid(win)) then return false end
            local buf = api.nvim_win_get_buf(win)
            return api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'oil'
          end

          for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
            if win_is_oil(win) then
              api.nvim_win_close(win, true)
              if vim.t.oil_sidebar_win == win then
                vim.t.oil_sidebar_win = nil
              end
              return
            end
          end

          vim.cmd('vsplit | Oil')
          vim.cmd('wincmd H')
          vim.cmd('vertical resize 30')

          local oilwin = api.nvim_get_current_win()
          vim.t.oil_sidebar_win = oilwin

          local function win_is_valid_editor(win)
            if not (win and api.nvim_win_is_valid(win)) then return false end
            local b = api.nvim_win_get_buf(win)
            return api.nvim_buf_is_valid(b) and vim.bo[b].filetype ~= 'oil'
          end

          if win_is_valid_editor(prevwin) then
            vim.t.oil_target_win = prevwin
          else
            for _, w in ipairs(api.nvim_tabpage_list_wins(0)) do
              if win_is_valid_editor(w) then
                vim.t.oil_target_win = w
                break
              end
            end
          end

          local buf = api.nvim_win_get_buf(oilwin)
          vim.wo[oilwin].number = false
          vim.wo[oilwin].relativenumber = false
          vim.wo[oilwin].winfixwidth = true

          vim.api.nvim_create_autocmd({ 'BufWinLeave', 'BufWipeout' }, {
            buffer = buf,
            callback = function()
              if vim.t.oil_sidebar_win == oilwin then
                vim.t.oil_sidebar_win = nil
              end
            end,
          })
        end,
        desc = 'Toggle Oil sidebar',
      },
    },

    cmd = { 'Oil' },
  },
}
