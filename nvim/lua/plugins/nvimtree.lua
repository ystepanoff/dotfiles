local function set_mappings(bufnr)
  local api = require('nvim-tree.api')
  api.config.mappings.default_on_attach(bufnr)
  vim.keymap.set('n', '-', api.tree.change_root_to_parent, { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set('n', 'u', api.tree.change_root_to_parent, { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set('n', '<CR>', api.node.open.edit, { buffer = bufnr, noremap = true, silent = true })
end

return {
  { 'nvim-tree/nvim-web-devicons', lazy = true },
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>e', function() require('nvim-tree.api').tree.toggle({ find_file = true, focus = true }) end, desc = 'Explorer (nvim-tree)' },
      { '<leader>E', function() require('nvim-tree.api').tree.find_file({ open = true, focus = true }) end, desc = 'Reveal file in explorer' },
    },
    opts = {
      on_attach = function(bufnr)
        set_mappings(bufnr)
      end,
      disable_netrw = true,
      hijack_netrw = true,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
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
    },
    config = function(_, opts)
      require('nvim-tree').setup(opts)
      vim.api.nvim_create_autocmd('QuitPre', {
        callback = function()
          local wins = vim.api.nvim_list_wins()
          if #wins == 1 then
            local bufname = vim.api.nvim_buf_get_name(0)
            if bufname:match('NvimTree_') then
              require('nvim-tree.api').tree.close()
            end
          end
        end,
      })
    end,
  },
}
