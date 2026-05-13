return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        map('n', ']h', function() gs.nav_hunk('next') end, 'Next git hunk')
        map('n', '[h', function() gs.nav_hunk('prev') end, 'Previous git hunk')

        map('n', '<leader>hp', gs.preview_hunk, 'Preview git hunk')
        map('n', '<leader>hi', gs.preview_hunk_inline, 'Preview hunk inline')

        map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
        map('n', '<leader>hS', gs.stage_buffer, 'Stage buffer')
        map('n', '<leader>hu', gs.stage_hunk, 'Unstage hunk (toggle)')
        map('n', '<leader>hR', gs.reset_buffer, 'Reset buffer')
        map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame line')
        map('n', '<leader>hd', gs.diffthis, 'Diff against index')
        map('n', '<leader>hD', function() gs.diffthis('~') end, 'Diff against last commit')
        map('n', '<leader>gtb', gs.toggle_current_line_blame, 'Toggle line blame')
        map('n', '<leader>gtd', gs.toggle_deleted, 'Toggle show deleted')
      end,
    },
  },
}
