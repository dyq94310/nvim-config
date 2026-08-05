-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local autosave_group = vim.api.nvim_create_augroup("user_autosave", { clear = true })

vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave", "FocusLost" }, {
  group = autosave_group,
  callback = function(args)
    local buf = args.buf
    if not vim.api.nvim_buf_is_valid(buf)
      or vim.bo[buf].buftype ~= ""
      or not vim.bo[buf].modifiable
      or vim.bo[buf].readonly
      or vim.api.nvim_buf_get_name(buf) == ""
      or not vim.bo[buf].modified then
      return
    end

    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent update")
    end)
  end,
})
