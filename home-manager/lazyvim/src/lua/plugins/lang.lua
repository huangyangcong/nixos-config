-- code from https://github.com/LazyVim/LazyVim/pull/1300 adapted for my needs

return {
  -- uncomment and add tools to ensure_installed below
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.remove(opts.ensure_installed, 1)
      vim.list_extend(opts.ensure_installed, {
        -- "lua-language-server",
        "marksman",
        -- blockchain and smart contracts
        -- "nomicfoundation-solidity-language-server",
        -- "solang",
        "solhint",
      })
      opts.ui = {
        icons = {
          package_installed = "✓",
          package_pending = "",
          package_uninstalled = "✗",
        },
      }
    end,
  },

  -- disable the fancy UI for the debugger
  { "rcarriga/nvim-dap-ui", enabled = false },

  -- which key integration
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>dw"] = { name = "+widgets" },
      },
    },
  },

  -- dap integration
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>de",
        function()
          require("dap.ui.widgets").centered_float(require("dap.ui.widgets").expression, { border = "none" })
        end,
        desc = "Eval",
        mode = { "n", "v" },
      },
      {
        "<leader>dwf",
        function()
          require("dap.ui.widgets").centered_float(require("dap.ui.widgets").frames, { border = "none" })
        end,
        desc = "Frames",
      },
      {
        "<leader>dws",
        function()
          require("dap.ui.widgets").centered_float(require("dap.ui.widgets").scopes, { border = "none" })
        end,
        desc = "Scopes",
      },
      {
        "<leader>dwt",
        function()
          require("dap.ui.widgets").centered_float(require("dap.ui.widgets").threads, { border = "none" })
        end,
        desc = "Threads",
      },
    },
    opts = function(_, opts)
      require("dap").defaults.fallback.terminal_win_cmd = "enew | set filetype=dap-terminal"
    end,
  },

  -- overwrite Rust tools inlay hints
  -- {
  --   "simrat39/rust-tools.nvim",
  --   optional = true,
  --   opts = {
  --     tools = {
  --       inlay_hints = {
  --         -- nvim >= 0.10 has native inlay hint support,
  --         -- so we don't need the rust-tools specific implementation any longer
  --         auto = not vim.fn.has("nvim-0.10"),
  --       },
  --     },
  --   },
  -- },

  -- overwrite Jdtls options
  {
    "mfussenegger/nvim-jdtls",
    optional = true,
    opts = function(_, opts)
      opts.settings = {
        java = {
          configuration = {
            updateBuildConfiguration = "automatic",
          },
          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
            useBlocks = true,
          },
          completion = {
            favoriteStaticMembers = {
              "org.assertj.core.api.Assertions.*",
              "org.junit.Assert.*",
              "org.junit.Assume.*",
              "org.junit.jupiter.api.Assertions.*",
              "org.junit.jupiter.api.Assumptions.*",
              "org.junit.jupiter.api.DynamicContainer.*",
              "org.junit.jupiter.api.DynamicTest.*",
              "org.mockito.Mockito.*",
              "org.mockito.ArgumentMatchers.*",
              "org.mockito.Answers.*",
            },
            importOrder = {
              "#",
              "java",
              "javax",
              "org",
              "com",
            },
          },
          contentProvider = { preferred = "fernflower" },
          eclipse = {
            downloadSources = true,
          },
          flags = {
            allow_incremental_sync = true,
            server_side_fuzzy_completion = true,
          },
          implementationsCodeLens = {
            enabled = false, --Don"t automatically show implementations
          },
          inlayHints = {
            parameterNames = { enabled = "all" },
          },
          maven = {
            downloadSources = true,
          },
          referencesCodeLens = {
            enabled = false, --Don"t automatically show references
          },
          references = {
            includeDecompiledSources = true,
          },
          saveActions = {
            organizeImports = true,
          },
          signatureHelp = { enabled = true },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
        },
      }
    end,
  },
  -- Setup null-ls with `clang_format`
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources, {
        nls.builtins.formatting.clang_format,
      })
    end,
  },
  {
    "skywind3000/asynctasks.vim",
    dependencies = {
      { "skywind3000/asyncrun.vim" },
    },
    config = function()
      vim.cmd([[
          let g:asyncrun_open = 8
          let g:asynctask_template = '~/.config/nvim/task_template.ini'
          let g:asynctasks_extra_config = ['~/.config/nvim/tasks.ini']
        ]])
    end,
    event = { "BufRead", "BufNew" },
  },
}
