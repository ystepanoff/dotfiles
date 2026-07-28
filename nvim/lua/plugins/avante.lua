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
        provider = "claude",
        providers = {
          claude = {
            endpoint      = "https://litellm.prod.dkng.tools",
            auth_type     = "api",
            api_key_name  = "ANTHROPIC_AUTH_TOKEN",
            model         = "us.anthropic.claude-opus-4-8",

            timeout = 120000,
            extra_request_body = {
              max_tokens = 4096,
            },
          },
        },

        auto_suggestions_provider = nil,

        -- avante defaults `files.add_current` to <leader>ac, which collides with
        -- our AvanteChat map below. On sidebar mount avante registers it GLOBALLY
        -- (no buffer-local scope), clobbering our chat map so it can't reopen after :q.
        mappings = {
          files = {
            add_current = "<leader>a.", -- moved off <leader>ac
          },
        },
      })

      -- Opus 4.8 rejects `temperature`; nuke it from every place avante caches it.
      pcall(function()
        local cfg = require("avante.config")
        if cfg.providers and cfg.providers.claude and cfg.providers.claude.extra_request_body then
          cfg.providers.claude.extra_request_body.temperature = nil
        end

        local Providers = require("avante.providers")
        local p = Providers.claude
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
