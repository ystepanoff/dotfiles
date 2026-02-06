return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = '<C-l>',
          accept_word = '<C-Right>',
          accept_line = '<C-Down>',
          next = '<C-]>',
          prev = '<C-\\>',
          dismiss = '<C-e>',
        },
      },
      panel = { enabled = false },
      filetypes = {
        yaml = true,
        markdown = true,
        gitcommit = true,
        ['.'] = false,
      },
    },
  },
}
