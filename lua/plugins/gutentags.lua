return {
  {
    "ludovicchabant/vim-gutentags",
    event = { "BufReadPost", "BufNewFile" }, -- 文件打开时加载
    config = function()
      vim.fn.mkdir(vim.fn.expand "~/.cache/nvim/tags", "p")
      vim.g.gutentags_enabled = 1
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_generate_on_missing = 1
      vim.g.gutentags_generate_on_new = 1

      vim.g.gutentags_cache_dir = vim.fn.expand "~/.cache/nvim/tags"
      vim.g.gutentags_ctags_binary = "ctags"
      vim.g.gutentags_ctags_extra_args = {
        "--fields=+lS",
        "--extras=+q",
        "--output-format=e-ctags",
      }

      vim.g.gutentags_project_root = { ".git", ".hg", ".svn", "Makefile", "package.json" }
      vim.g.gutentags_define_advanced_commands = 1

      vim.opt.tags = { "./tags;", "~/.cache/nvim/tags" }

      _G.gutentags_status = "ready"

      -- 🔥 这里开始加 Gutentags 状态监听！

      -- 开始更新时
      vim.api.nvim_create_autocmd("User", {
        pattern = "GutentagsUpdating",
        callback = function() _G.gutentags_status = "updating..." end,
      })

      -- 更新完成时
      vim.api.nvim_create_autocmd("User", {
        pattern = "GutentagsUpdated",
        callback = function()
          _G.gutentags_status = "updated ✓"
          vim.defer_fn(function() _G.gutentags_status = "ready" end, 3000) -- 3秒后恢复 ready 状态
        end,
      })

      -- 🔥 监听结束
    end,
  },
}
