return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["html.jinja"] = { "djlint" },
        ["json.jinja"] = { "json_jinja" },
      },
      formatters = {
        djlint = {
          prepend_args = { "--profile", "jinja" },
        },
        json_jinja = {
          command = "python3",
          args = {
            vim.fn.stdpath("config") .. "/scripts/json-jinja-format.py",
          },
        },
      },
    },
  },
}
