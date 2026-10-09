return {
  "toppair/peek.nvim",
  ft = { "markdown" },
  build = "deno task --quiet build fast", -- if using Deno
  config = function()
    require("peek").setup()
    vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
    vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
  end,
  keys = {
    { "<leader>mp", "<cmd>PeekOpen<cr>", desc = "Open Markdown Preview" },
    { "<leader>mc", "<cmd>PeekClose<cr>", desc = "Close Markdown Preview" },
  },
}
