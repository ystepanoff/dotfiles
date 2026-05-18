local o = vim.opt

o.number = true
o.relativenumber = false
o.ignorecase = true
o.smartcase = true
o.wrap = false
o.cursorline = true
o.splitright = true
o.splitbelow = true
o.termguicolors = true
o.signcolumn = 'yes:1'
o.updatetime = 200
o.timeout = true
o.timeoutlen = 500
o.clipboard = 'unnamedplus'
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.smartindent = true
o.equalalways = false
o.undofile = true
o.scrolloff = 8
o.sidescrolloff = 8
o.confirm = true
o.fillchars = { eob = ' ' }

-- keep selection when indenting/dedenting in visual mode
vim.keymap.set('v', '<', '<gv', { desc = 'Dedent and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent and reselect' })

-- Tab/Shift-Tab as ergonomic aliases for indent/dedent
vim.keymap.set('v', '<Tab>',   '>gv', { desc = 'Indent selection' })
vim.keymap.set('v', '<S-Tab>', '<gv', { desc = 'Dedent selection' })
