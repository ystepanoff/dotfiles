return {
  {
    "benomahony/uv.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    event = "VeryLazy",
    opts = {
      auto_activate_venv = true,
      notify_activate_venv = true,
      picker_integration = true,
      execution = {
        run_command = "uv run python",
        notify_output = true,
        notification_timeout = 10000,
      },
      auto_commands = true,
    },
  },
}
