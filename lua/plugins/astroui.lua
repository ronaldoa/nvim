-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  "AstroNvim/astroui",
  opts = {
    colorscheme = "astrodark",
    highlights = {
      init = {},
      astrodark = {},
    },
    icons = {
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
    -- ✨ 加入自定义 statusline
    status = {
      attributes = {
        mode = { bold = true },
      },
      separators = {
        left = "",
        right = "",
      },
      components = {
        active = {
          -- 左边
          {
            { provider = "mode" },
            { provider = "git_branch" },
            { provider = "diagnostics" },
            { provider = "file_info" },
          },
          -- 中间
          {
            {
              provider = function()
                return "[tags: " .. (_G.gutentags_status or "N/A") .. "]"
              end,
              hl = function()
                local status = _G.gutentags_status or "ready"
                if status:find("updating") then
                  return { fg = "yellow", bold = true }
                elseif status:find("updated") then
                  return { fg = "green", bold = true }
                else
                  return { fg = "gray", italic = true }
                end
              end,
            },
          },
          -- 右边
          {
            { provider = "lsp" },
            { provider = "position" },
          },
        },
        inactive = {
          {
            { provider = "file_info" },
          },
        },
      },
    },
  },
}

