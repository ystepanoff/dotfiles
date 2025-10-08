return {
  {
    "yetone/avante.nvim",
    build = "make",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "echasnovski/mini.icons",
    },
    event = "VeryLazy",
    config = function()
      require("avante").setup({
        provider = "bedrock",
        providers = {
          bedrock = {
            model       = "us.anthropic.claude-sonnet-4-5-20250929-v1:0",
            aws_profile = "draftkingsdev",
            aws_region  = "us-east-1",

            timeout = 60000,
            extra_request_body = {
              anthropic_version = "bedrock-2023-05-31",
              temperature = 0.3,
              max_tokens  = 512,
            },

            is_env_set    = function() return true end,
            parse_api_key = function() return nil end,
          },
        },

        auto_suggestions_provider = nil,
      })

      -- keys
      vim.keymap.set("n", "<leader>ac", "<cmd>AvanteChat<CR>", { desc = "Avante: Chat" })
      vim.keymap.set("v", "<leader>ae", "<cmd>AvanteAsk<CR>",  { desc = "Avante: Ask selection" })
    end,
  },
}
