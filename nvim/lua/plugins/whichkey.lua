return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = {
      spelling = true,
    },
    window = {
      border = "single",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    vim.keymap.set("n", "<leader>h", function()
      require("which-key").show()
    end, { desc = "Show which-key popup" })
  end,
}
