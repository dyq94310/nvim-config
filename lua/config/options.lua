-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.filetype.add({
  extension = {
    j2 = function(path)
      return path:match("%.json%.j2$") and "json.jinja" or "html.jinja"
    end,
    jinja = function(path)
      return path:match("%.json%.jinja$") and "json.jinja" or "html.jinja"
    end,
    jinja2 = function(path)
      return path:match("%.json%.jinja2$") and "json.jinja" or "html.jinja"
    end,
  },
})

local function setup_jinja_syntax(buf)
  local base_syntax = vim.bo[buf].filetype == "json.jinja" and "json" or "html"
  vim.bo[buf].syntax = base_syntax
  vim.cmd("runtime! syntax/" .. base_syntax .. ".vim")
  vim.cmd("runtime! syntax/jinja.vim")
  vim.bo[buf].syntax = base_syntax .. ".jinja"
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html.jinja", "json.jinja" },
  callback = function(args)
    setup_jinja_syntax(args.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  callback = function(args)
    if vim.bo[args.buf].filetype == "html.jinja" or vim.bo[args.buf].filetype == "json.jinja" then
      setup_jinja_syntax(args.buf)
    end
  end,
})

vim.schedule(function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf)
      and (vim.bo[buf].filetype == "html.jinja" or vim.bo[buf].filetype == "json.jinja") then
      setup_jinja_syntax(buf)
    end
  end
end)
