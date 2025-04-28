return {
  {
    "Yggdroot/LeaderF",
    build = ":LeaderfInstallCExtension",
    cmd = { "LeaderfFile", "LeaderfTag", "LeaderfBuffer", "LeaderfMru" },
    config = function()
      vim.g.Leaderf_ShowHidden = 1
      vim.g.Leaderf_IgnoreCurrentBuffer = 1
      vim.g.Leaderf_SmartMatch = 1
      vim.g.Leaderf_IncSearch = 1
      vim.g.Lf_RootMarkers = { '.git', '.hg', '.svn', 'Makefile', 'package.json' }
      vim.g.Lf_WorkingDirectoryMode = 'Ac'

      -- 美化 popup
      vim.g.Lf_WindowPosition = 'popup'
      vim.g.Lf_PopupHeight = 0.6
      vim.g.Lf_PopupWidth = 0.8
      vim.g.Lf_PopupBorder = 1
      vim.g.Lf_PopupTransparency = 10

      -- Git 状态提示
      vim.g.Lf_ShowGitStatus = 1
      vim.g.Lf_UseVersionControlTool = 1

      -- 搜索高亮颜色
      vim.cmd [[
        hi Lf_hl_match guifg=#FF9E64 guibg=NONE gui=bold
        hi Lf_hl_matchRefine guifg=#FF5555 guibg=NONE gui=bold
      ]]

      -- 智能 project 文件搜索
      local function smart_project_search()
        local total_files = tonumber(vim.fn.systemlist("git ls-files | wc -l")[1]) or 0
        if total_files > 5000 then
          vim.cmd('Leaderf rg --files')
        else
          vim.cmd('LeaderfFile --project')
        end
      end

      vim.keymap.set('n', '<leader>ff', ':LeaderfFile<CR>', { desc = "LeaderF search files in cwd" })
      vim.keymap.set('n', '<leader>fp', smart_project_search, { desc = "LeaderF smart project files" })
      vim.keymap.set('n', '<leader>fg', ':LeaderfRg<CR>', { desc = "LeaderF search content" })
      vim.keymap.set('n', '<leader>ft', ':LeaderfTag<CR>', { desc = "LeaderF search tags" })
      vim.keymap.set('n', '<leader>fb', ':LeaderfBuffer<CR>', { desc = "LeaderF search buffers" })

      -- Visual 模式下选中内容搜索
      local function leaderf_search_visual()
        vim.cmd('normal! "vy')
        local word = vim.fn.getreg('v')
        word = vim.fn.escape(word, ' ')
        vim.cmd('Leaderf rg --no-ignore ' .. word)
      end
      vim.keymap.set('v', '<leader>fg', leaderf_search_visual, { desc = "LeaderF rg search visual selected text" })
    end,
  },
}

