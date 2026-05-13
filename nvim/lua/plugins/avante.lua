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
            model       = "us.anthropic.claude-opus-4-7",
            aws_profile = "draftkingsdev",
            aws_region  = "us-east-1",

            timeout = 120000,
            extra_request_body = {
              anthropic_version = "bedrock-2023-05-31",
              max_tokens  = 4096,
            },

            is_env_set    = function() return true end,
            parse_api_key = function() return nil end,
          },
        },

        auto_suggestions_provider = nil,
      })

      -- Opus 4.7 on Bedrock rejects `temperature`; nuke it from every place avante caches it.
      pcall(function()
        local cfg = require("avante.config")
        if cfg.providers and cfg.providers.bedrock and cfg.providers.bedrock.extra_request_body then
          cfg.providers.bedrock.extra_request_body.temperature = nil
        end

        -- Force the providers metatable to materialize bedrock and strip temperature there too.
        local Providers = require("avante.providers")
        local p = Providers.bedrock
        if p and p.extra_request_body then
          p.extra_request_body.temperature = nil
        end
      end)

      -- keys
      vim.keymap.set("n", "<leader>ac", "<cmd>AvanteChat<CR>",   { desc = "Avante: Chat" })
      vim.keymap.set("v", "<leader>ae", "<cmd>AvanteAsk<CR>",    { desc = "Avante: Ask selection" })
      vim.keymap.set("n", "<leader>at", "<cmd>AvanteToggle<CR>", { desc = "Avante: Toggle" })
      vim.keymap.set("v", "<leader>aE", "<cmd>AvanteEdit<CR>",   { desc = "Avante: Edit selection" })
      vim.keymap.set("n", "<leader>aR", "<cmd>AvanteRefresh<CR>",{ desc = "Avante: Refresh" })
    end,
  },
}
