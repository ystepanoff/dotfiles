return {
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-tree.lua" },
    keys = {
      {
        "<leader>gg",
        function()
          local dir

          local ok_tree, api = pcall(require, "nvim-tree.api")
          if ok_tree and api.tree.is_visible() then
            local node = api.tree.get_node_under_cursor()
            if node and node.absolute_path then
              if node.type == "directory" then
                dir = node.absolute_path
              else
                dir = vim.fn.fnamemodify(node.absolute_path, ":h")
              end
            end
          end

          if not dir or dir == "" then
            local buf = vim.api.nvim_buf_get_name(0)
            dir = (buf ~= "" and vim.fn.fnamemodify(buf, ":h")) or vim.loop.cwd()
          end

          local git_root
          local path = dir
          while path and path ~= "/" do
            local candidate = path .. "/.git"
            if vim.loop.fs_stat(candidate) then
              git_root = path
              break
            end
            path = vim.fn.fnamemodify(path, ":h")
          end

          local target = git_root or dir
          vim.cmd("lcd " .. vim.fn.fnameescape(target))
          vim.cmd("LazyGit")

          if not git_root then
            vim.schedule(function()
              vim.notify("No Git repo found; opened LazyGit in: " .. target, vim.log.levels.INFO)
            end)
          end
        end,
        mode = "n",
        desc = "LazyGit (smart repo root)",
        nowait = true,
        silent = true,
      },
    },
    config = function()
      vim.g.lazygit_floating_window_use_plenary = 1
      vim.g.lazygit_use_neovim_remote = 1
    end,
  },
}
