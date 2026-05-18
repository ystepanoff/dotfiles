return {
  "stevearc/conform.nvim",
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
  },

  config = function(_, opts)
    require("conform").setup(opts)

    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
      require("conform").format({ async = false, lsp_fallback = true })
    end, { desc = "Format file" })
  end,
}
