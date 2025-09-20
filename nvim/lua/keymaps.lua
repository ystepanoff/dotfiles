local map = vim.keymap.set

-- Telescope
map('n', '<leader>ff', function() require('telescope.builtin').find_files() end, { desc = 'Find files' })
map('n', '<leader>fg', function() require('telescope.builtin').live_grep() end,  { desc = 'Live grep' })
map('n', '<leader>fb', function() require('telescope.builtin').buffers() end,    { desc = 'Buffers' })
map('n', '<leader>fh', function() require('telescope.builtin').help_tags() end,  { desc = 'Help tags' })

-- File explorer
map('n', '<leader>e', function() vim.cmd('Oil') end, { desc = 'File explorer (oil)' })

-- Which Key
map('n', '<leader>?', function() require('which-key').show() end, { desc = 'Show which-key popup' })

