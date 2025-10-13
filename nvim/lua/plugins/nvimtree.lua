return {
  { 'nvim-tree/nvim-web-devicons', lazy = true },
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>e', function() require('nvim-tree.api').tree.toggle({ find_file = true, focus = true }) end,
        desc = 'Explorer (nvim-tree)' },
      { '<leader>E', function() require('nvim-tree.api').tree.find_file({ open = true, focus = true }) end,
        desc = 'Reveal file in explorer' },
    },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,

      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = false,
      },

      view = {
        width = 34,
        side = 'left',
        preserve_window_proportions = true,
      },

      renderer = {
        highlight_git = true,
        highlight_opened_files = 'name',
        root_folder_label = false,
        indent_markers = { enable = true },
        icons = {
          git_placement = 'after',
          show = { folder_arrow = true, file = true, folder = true, git = true },
        },
      },

      filters = {
        dotfiles = false,
        git_ignored = false,
      },

      git = { enable = true, ignore = false, timeout = 400 },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = false,
        debounce_delay = 100,
      },

      actions = {
        open_file = {
          quit_on_open = false,
          resize_window = false,
          window_picker = {
            enable = true,
            chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
          },
        },
        change_dir = { enable = true, restrict_above_cwd = false },
      },

      live_filter = { prefix = ' ', always_show_folders = false },

      -- Trash vs permanent delete (adjust to taste)
      -- NOTE: nvim-tree uses vim.fn.delete by default (permanent).
      -- To move to trash on macOS, set this and have `trash` cli installed:
      -- system_open = { cmd = 'open' }, -- for opening files externally
    },
    config = function(_, opts)
      require('nvim-tree').setup(opts)

      local api = require('nvim-tree.api')
      vim.api.nvim_create_autocmd('QuitPre', {
        callback = function()
          local wins = vim.api.nvim_list_wins()
          if #wins == 1 then
            local bufname = vim.api.nvim_buf_get_name(0)
            if bufname:match('NvimTree_') then
              api.tree.close()
            end
          end
        end,
      })
    end,
  },
}
