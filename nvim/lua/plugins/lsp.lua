return {
  { 'williamboman/mason.nvim', config = true },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'neovim/nvim-lspconfig' },
  {
    'hrsh7th/cmp-nvim-lsp',
    config = function()
      do
        local util = vim.lsp.util
        local orig = util.jump_to_location
        util.jump_to_location = function(location, enc, opts)
          local loc = location or {}
          local uri = loc.uri or loc.targetUri
          local range = loc.range or loc.targetSelectionRange or loc.targetRange

          if type(uri) ~= 'string' or not uri:match('^file:') then
            vim.notify('LSP: non-file location (skipped)', vim.log.levels.WARN)
            return false
          end
          local fname = vim.uri_to_fname(uri)
          if vim.fn.filereadable(fname) ~= 1 then
            vim.notify('LSP: location not readable: ' .. fname, vim.log.levels.WARN)
            return false
          end

          local ok = pcall(orig, loc, enc, opts)
          if ok then return true end

          vim.cmd('edit ' .. vim.fn.fnameescape(fname))
          local line = ((range and range.start and range.start.line) or 0) + 1
          local col  = (range and range.start and range.start.character) or 0
          local maxline = vim.api.nvim_buf_line_count(0)
          if line < 1 then line = 1 end
          if line > maxline then line = maxline end
          if col < 0 then col = 0 end
          pcall(vim.api.nvim_win_set_cursor, 0, { line, col })
          return true
        end
      end

      local icons = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = icons.Error,
            [vim.diagnostic.severity.WARN]  = icons.Warn,
            [vim.diagnostic.severity.HINT]  = icons.Hint,
            [vim.diagnostic.severity.INFO]  = icons.Info,
          },
        },
        virtual_text = {
          prefix = "●",
          spacing = 2,
          severity = { min = vim.diagnostic.severity.WARN },
        },
        float = { border = "rounded" },
        severity_sort = true,
        update_in_insert = false,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
          end

          local function filter_file_locs(locs)
            local out = {}
            for _, loc in ipairs(locs or {}) do
              local uri = loc.uri or loc.targetUri
              if type(uri) == 'string' and uri:match('^file:') then
                local fname = vim.uri_to_fname(uri)
                if vim.fn.filereadable(fname) == 1 then
                  table.insert(out, loc)
                end
              end
            end
            return out
          end

          map('gd', function()
            local params = vim.lsp.util.make_position_params()
            local clients = vim.lsp.get_clients({ bufnr = bufnr })
            if #clients == 0 then return end
            clients[1].request('textDocument/definition', params, function(err, result)
              if err then
                vim.notify('LSP definition error: ' .. err.message, vim.log.levels.WARN)
                return
              end
              local results = result
              if not results then return end
              if results.uri or results.targetUri then results = { results } end
              local files_only = filter_file_locs(results)
              if #files_only == 0 then
                vim.notify('No file-backed definitions found (likely virtual/library).', vim.log.levels.INFO)
                return
              end
              vim.lsp.util.jump_to_location(files_only[1], 'utf-16')
            end, bufnr)
          end, 'Goto definition (safe)')

          map('gr', function() require('telescope.builtin').lsp_references() end, 'References')
          map('gD', function() require('telescope.builtin').lsp_type_definitions() end, 'Type definition')
          map('gi', function() require('telescope.builtin').lsp_implementations({ reuse_window = false }) end, 'Implementations')

          map('K',  vim.lsp.buf.hover,               'Hover docs')
          map('<leader>rn', vim.lsp.buf.rename,      'Rename symbol')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
          map('[d', vim.diagnostic.goto_prev,        'Prev diagnostic')
          map(']d', vim.diagnostic.goto_next,        'Next diagnostic')

          if vim.lsp.inlay_hint then pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr }) end
        end,
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      capabilities.offsetEncoding = { 'utf-16' }

      pcall(function()
        require('mason-lspconfig').setup({
          ensure_installed = {
            'lua_ls',
            'pyright',
            'ruff',
            'ts_ls',
            'gopls',
            'rust_analyzer',
            'omnisharp',
          },
        })
      end)

      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
            workspace = { checkThirdParty = false },
            telemetry  = { enable = false },
          },
        },
      })

      vim.lsp.config('pyright',        { capabilities = capabilities })
      vim.lsp.config('ruff',           { capabilities = capabilities })

      vim.lsp.config('ts_ls', {
        capabilities = capabilities,
        settings = {
          typescript = { preferences = { preferGoToSourceDefinition = true } },
          javascript = { preferences = { preferGoToSourceDefinition = true } },
        },
      })

      vim.lsp.config('gopls',          { capabilities = capabilities })
      vim.lsp.config('rust_analyzer',  { capabilities = capabilities })

      local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'
      vim.lsp.config('omnisharp', {
        cmd = { mason_bin .. '/OmniSharp', '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
        capabilities = capabilities,
        settings = {
          omnisharp = {
            enableEditorConfigSupport = true,
            enableRoslynAnalyzers     = true,
            organizeImportsOnFormat   = true,
            analyzeOpenDocumentsOnly  = true,
          },
        },
        handlers = {
          ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
            if result and result.diagnostics then
              result.diagnostics = vim.tbl_filter(function(d)
                local code = tostring(d.code or '')
                if code:match('^IDE') then return false end
                return d.severity <= vim.lsp.protocol.DiagnosticSeverity.Warning
              end, result.diagnostics)
            end
            vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
          end,
        },
      })

      for _, name in ipairs({ 'lua_ls','pyright','ruff','ts_ls','gopls','rust_analyzer','omnisharp' }) do
        vim.lsp.enable(name)
      end
    end,
  },
}
