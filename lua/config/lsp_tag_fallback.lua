-- 文件名：lua/config/lsp_tag_fallback.lua

local M = {}

-- 跳转到定义（LSP 优先，失败 fallback tags）
function M.goto_definition()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result)
    if err or not result or vim.tbl_isempty(result) then
      vim.cmd('normal! ^]')
    else
      vim.lsp.util.jump_to_location(result[1], 'utf-8')
    end
  end)
end

-- 查找引用（LSP 优先，失败用 LeaderF Rg fuzzy search）
function M.goto_references()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, 'textDocument/references', params, function(err, result)
    if err or not result or vim.tbl_isempty(result) then
      local word = vim.fn.expand("<cword>")
      vim.cmd('Leaderf rg --no-ignore ' .. word)
    else
      vim.lsp.util.locations_to_items(result)
      vim.fn.setqflist(vim.lsp.util.locations_to_items(result))
      vim.cmd('copen')
    end
  end)
end

return M

