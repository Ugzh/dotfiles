return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters = {
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
          end,
        },
        ["markdownlint-cli2"] = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
      },
      formatters_by_ft = {
        javascript = { "eslint_d", "prettier" },
        typescript = { "eslint_d", "prettier" },
        javascriptreact = { "eslint_d", "prettier" },
        typescriptreact = { "eslint_d", "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        svelte = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier", "markdown-toc" },
        go = { "gofmt" },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      },
    })

    -- Configure ESLint formatter to respect local config
    conform.formatters.eslint_d = {
      command = "eslint_d",
      args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
      stdin = true,
      cwd = require("conform.util").root_file({
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.yaml",
        ".editorconfig",
        ".eslintrc.yml",
        ".eslintrc.json",
        "eslint.config.js",
        "package.json",
      }),
    }

    -- Configure Prettier to use local config files
    conform.formatters.prettier = {
      command = "prettier",
      args = { "--stdin-filepath", "$FILENAME" },
      stdin = true,
      cwd = require("conform.util").root_file({
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.yml",
        ".prettierrc.yaml",
        ".prettierrc.js",
        ".prettierrc.cjs",
        "prettier.config.js",
        "prettier.config.cjs",
        "package.json",
        "angular.json",
      }),
    }

    -- Configure stylua to respect stylua.toml
    conform.formatters.stylua = {
      command = "stylua",
      args = { "--stdin-filepath", "$FILENAME", "-" },
      stdin = true,
      cwd = require("conform.util").root_file({ "stylua.toml", ".stylua.toml" }),
    }

    -- Create a command to toggle format on save
    vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
      local current_config = conform.get_format_options()
      if current_config.format_on_save then
        conform.setup({ format_on_save = nil })
        print("Format on save: disabled")
      else
        conform.setup({
          format_on_save = {
            lsp_fallback = true,
            async = false,
            timeout_ms = 1000,
          },
        })
        print("Format on save: enabled")
      end
    end, { desc = "Toggle format on save" })
  end,
}
