return {
  {
    'kdheepak/lazygit.nvim',
    keys = {
      { '<leader>gg', function() vim.cmd('LazyGit') end, desc = 'LazyGit' },
    },
  },
}
