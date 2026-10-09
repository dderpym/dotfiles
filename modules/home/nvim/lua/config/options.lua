-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt
local g = vim.g

opt.winborder = "rounded"
g.root_spec = { "cwd" }

package.preload["notify"] = function()
  return setmetatable({}, {
    __call = function(_, ...)
      return Snacks.notifier(...)
    end,
    __index = function(_, key)
      return Snacks.notifier[key]
    end,
  })
end
