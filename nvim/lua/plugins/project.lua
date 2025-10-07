return {
  {
    'ahmedkhalf/project.nvim',
    config = function()
      require('project_nvim').setup({
        -- Remove "lsp" from here to avoid deprecated call
        detection_methods = { 'pattern' },
        patterns = { '.git', 'Makefile', 'package.json', 'pyproject.toml', 'go.mod' },
      })
      require('telescope').load_extension('projects')
    end,
  },
}
