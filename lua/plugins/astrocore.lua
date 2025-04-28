-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = true,
      cmp = true,
      diagnostics = { virtual_text = true, virtual_lines = false },
      highlighturl = true,
      notifications = true,
    },
    -- Diagnostics configuration
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- filetype settings
    filetypes = {
      extension = { foo = "fooscript" },
      filename = { [".foorc"] = "fooscript" },
      pattern = { [".*/etc/foo/.*"] = "fooscript" },
    },
    -- vim options
    options = {
      opt = {
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "yes",
        wrap = false,
        encoding = "utf-8",
        fileencoding = "utf-8",
        fileencodings = { "utf-8", "gbk" },
        tags = { "./tags;", "tags;" },
      },
      g = {
        -- 可以设置 vim.g.xxx
      },
    },
    -- key mappings
    mappings = {
      n = {
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },
        ["gd"] = {
          function()
            require("config.lsp_tag_fallback").goto_definition()
          end,
          desc = "LSP goto definition (fallback tags)",
        },
        ["gr"] = {
          function()
            require("config.lsp_tag_fallback").goto_references()
          end,
          desc = "LSP find references (fallback ripgrep)",
        },
      },
    },

    -- ✨ 这里新增了 statusline 配置 ✨
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

