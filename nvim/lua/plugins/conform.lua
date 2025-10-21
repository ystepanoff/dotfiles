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
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      go = { "gofmt" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      csharp = { "csharpier" },
    },

    --format_on_save = {
    --  timeout_ms = 1000,
    --  lsp_fallback = true,
    --},
  },

  config = function(_, opts)
    require("conform").setup(opts)

    vim.keymap.set({ "n", "v" }, "<leader>f", function()
      require("conform").format({ async = false, lsp_fallback = true })
    end, { desc = "Format file" })
  end,
}
