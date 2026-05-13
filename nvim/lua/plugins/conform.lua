return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format", "black" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      javascriptreact = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      go = { "gofmt" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      csharp = { "csharpier" },
      json = { "jq" },
    },

    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
      return { timeout_ms = 1000, lsp_fallback = true }
    end,
  },

  config = function(_, opts)
    require("conform").setup(opts)

    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
      require("conform").format({ async = false, lsp_fallback = true })
    end, { desc = "Format file" })

    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then vim.b.disable_autoformat = true else vim.g.disable_autoformat = true end
    end, { desc = "Disable autoformat-on-save", bang = true })

    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, { desc = "Re-enable autoformat-on-save" })
  end,
}
