return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "html.jinja", "json.jinja" },
        callback = function(args)
          local config = vim.lsp.config.jinja_lsp
          if config and #vim.lsp.get_clients({ bufnr = args.buf, name = "jinja_lsp" }) == 0 then
            vim.lsp.start(config, { bufnr = args.buf })
          end

          local function format_jinja()
            require("conform").format({ bufnr = args.buf, async = false, timeout_ms = 5000 })
          end
          vim.keymap.set("n", "<leader>cf", format_jinja, { buffer = args.buf, desc = "Format Jinja" })
          vim.keymap.set("n", "<leader>cF", format_jinja, { buffer = args.buf, desc = "Format Jinja" })
        end,
      })
    end,
    opts = {
      servers = {
        jinja_lsp = {
          filetypes = { "jinja", "html.jinja", "json.jinja" },
        },
      },
    },
  },
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
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        ["html.jinja"] = { "djlint" },
        ["json.jinja"] = { "json_jinja" },
      },
      linters = {
        djlint = {
          args = {
            "--profile",
            "jinja",
            "--linter-output-format",
            "{line}:{code}: {message}",
            "-",
          },
        },
        json_jinja = {
          cmd = "python3",
          stdin = true,
          args = {
            vim.fn.stdpath("config") .. "/scripts/json-jinja-format.py",
            "--lint",
          },
          stream = "stderr",
          ignore_exitcode = true,
          parser = require("lint.parser").from_pattern(
            "(%d+):(%d+): (.*)",
            { "lnum", "col", "message" },
            nil,
            { source = "json-jinja", severity = vim.diagnostic.severity.ERROR },
            {}
          ),
        },
      },
    },
  },
}
