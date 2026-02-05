return {
  { 'numToStr/Comment.nvim', opts = {} },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup({})
      -- cmp integration
      local cmp_ok, cmp = pcall(require, 'cmp')
      if cmp_ok then
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
      end
    end
  },
  { 'echasnovski/mini.surround', version = '*', opts = {} },
  { 'echasnovski/mini.move', version = '*', opts = {
    mappings = {
      left = '<e',
      right = '>e',
      down = ']e',
      up = '[e',
      line_left = '<e',
      line_right = '>e',
      line_down = ']e',
      line_up = '[e',
    },
  } },
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },
}
