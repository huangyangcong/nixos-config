{ inputs, config, pkgs, lib, ... }:
let
  telescope-fzf-native-nvim = pkgs.vimPlugins.telescope-fzf-native-nvim;
  nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
  treesitter-parsers-deps = pkgs.symlinkJoin {
    name = "treesitter-parsers-deps";
    paths = nvim-treesitter.dependencies;
  };
in
{
  xdg.configFile = {
    "nvim/init.lua".text = ''
      vim.opt.runtimepath:append("${nvim-treesitter}")
      vim.opt.runtimepath:append("${treesitter-parsers-deps}")
      vim.opt.runtimepath:append("${telescope-fzf-native-nvim}")
      -- bootstrap lazy.nvim, LazyVim and your plugins
      require("config.lazy")({
        debug = false,
        defaults = {
          lazy = true,
          -- cond = false,
        },
        nv = {
          colorscheme = "onedark", -- colorscheme setting for either onedark.nvim or github-theme
          codeium_support = false, -- enable codeium extension
          copilot_support = false, -- enable copilot extension
          coverage_support = true, -- enable coverage extension
          dap_support = true, -- enable dap extension
          none_ls = true,
          lang = {
            clangd = true, -- enable clangd and cmake extension
            docker = true, -- enable docker extension
            elixir = false, -- enable elixir extension
            go = true, -- enable go extension
            java = true, -- enable java extension
            nodejs = true, -- enable nodejs (typescript, css, html, json) extension
            python = true, -- enable python extension
            ruby = false, -- enable ruby extension
            rust = true, -- enable rust extension
            terraform = false, -- enable terraform extension
            tex = false, -- enable tex extension
            yaml = true, -- enable yaml extension
          },
          rest_support = true, -- enable rest.nvim extension
          test_support = true, -- enable test extension
        },
        performance = {
          cache = {
            enabled = true,
          },
        },
      })
      -- Add Treesitter Path
      vim.opt.runtimepath = vim.opt.runtimepath + "${pkgs.vimPlugins.nvim-treesitter.withAllGrammars}"
      -- treesitter compiler error fix
      require("nvim-treesitter.install").compilers = { "clang++" }
    '';
  };
  home.file = {
    ".config/nvim" = {
      source = ./src;
      recursive = true;
    };
    ".config/nvim/lua/plugins/lang_extra.lua".text = ''
      return {
        -- overwrite Rust tools adapter
        {
          "simrat39/rust-tools.nvim",
          optional = true,
          opts = function()
            local extension_path = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/"
            local codelldb_path = extension_path .. 'adapter/codelldb'
            local liblldb_path = extension_path .. 'lldb/lib/liblldb.so'
            local adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
            require("dap").adapters.codelldb = adapter
            require("dap").adapters.rust = adapter
            require("dap").configurations.rust = {
              {
                type = "rust",
                request = "launch",
                name = "codelldb",
                program = function()
                  local metadata_json = vim.fn.system "cargo metadata --format-version 1 --no-deps"
                  local metadata = vim.fn.json_decode(metadata_json)
                  local target_name = metadata.packages[1].targets[1].name
                  local target_dir = metadata.target_directory
                  return target_dir .. "/debug/" .. target_name
                end,
                args = function()
                  local inputstr = vim.fn.input("Params: ", "")
                  local params = {}
                  local sep = "%s"
                  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
                    table.insert(params, str)
                  end
                  return params
                end,
              },
            }
            return {
              dap = {
                adapter = adapter
              },
              tools = {
                inlay_hints = {
                  -- nvim >= 0.10 has native inlay hint support,
                  -- so we don't need the rust-tools specific implementation any longer
                  auto = not vim.fn.has("nvim-0.10"),
                },
              }
            }
          end,
        },
        -- change jdk version
        {
          "mfussenegger/nvim-jdtls",
          optional = true,
          opts = function(_, opts)
            -- points to $HOME/.local/share/nvim/mason/packages/jdtls/
            local jdtls_path = require("mason-registry").get_package("jdtls"):get_install_path()
            -- get the current OS
            local os
            if vim.fn.has("mac") == 1 then
              os = "mac"
            elseif vim.fn.has("unix") == 1 then
              os = "linux"
            elseif vim.fn.has("win32") == 1 then
              os = "win"
            end
            opts.cmd = {
              "${pkgs.openjdk17.home}/bin/java",
              "-Declipse.application=org.eclipse.jdt.ls.core.id1",
              "-Dosgi.bundles.defaultStartLevel=4",
              "-Declipse.product=org.eclipse.jdt.ls.core.product",
              "-Dosgi.sharedConfiguration.area=" .. jdtls_path .. "/config_" .. os,
              "-Dosgi.sharedConfiguration.area.readOnly=true",
              "-Dosgi.checkConfiguration=true",
              "-Dosgi.configuration.cascaded=true",
              "-Dlog.level=ALL",
              "-javaagent:" .. jdtls_path .. "/lombok.jar",
              "-Xms1g",
              "-jar",
              vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
              "--add-modules=ALL-SYSTEM",
              "--add-opens",
              "java.base/java.util=ALL-UNNAMED",
              "--add-opens",
              "java.base/java.lang=ALL-UNNAMED",
            }
          end,
        },
        -- remove treesitter for stylua
        {
          "williamboman/mason.nvim",
          opts = function(_, opts)
            table.remove(opts.ensure_installed, 1)
          end,
        },
        -- set format for stylua
        {
          "nvimtools/none-ls.nvim",
          opts = function(_, opts)
            local nls = require("null-ls")
            opts.sources = vim.list_extend(opts.sources, {
              nls.builtins.formatting.stylua.with({ command = "${pkgs.stylua}/bin/stylua" })
            })
          end,
        },
        -- set path for clangd/rust_analyzer/lua_ls/solang
        {
          "neovim/nvim-lspconfig",
          ---@class PluginLspOpts
          opts = {
            inlay_hints = { enabled = vim.fn.has("nvim-0.10") },
            -- ---@type lspconfig.options
            servers = {
              marksman = {
                mason = false,
                cmd = {
                  "${pkgs.marksman}/bin/marksman"
                }
              },
              clangd = {
                mason = false,
                cmd = {
                  "${pkgs.clang-tools_16}/bin/clangd",
                  "--background-index",
                  "--clang-tidy",
                  "--header-insertion=iwyu",
                  "--completion-style=detailed",
                  "--function-arg-placeholders",
                  "--fallback-style=llvm",
                },
              },
              rust_analyzer = {
                mason = false,
                cmd = {
                  "${pkgs.rust-analyzer}/bin/rust-analyzer"
                }
              },
              lua_ls = {
                mason = false,
                cmd = {
                  "${pkgs.lua-language-server}/bin/lua-language-server"
                }
              },
              --solang = {
              --  mason = false,
              --  cmd = {
              --    "${pkgs.solang_0_3_2}/bin/solang",
              --    "language-server",
              --    "--target",
              --    "evm",
              --    "-I",
              --    "node_modules",
              --    "-m",
              --    "@openzeppelin=node_modules/@openzeppelin",
              --  },
              --},
              -- sourcekit will be automatically installed with mason and loaded with lspconfig
              -- sourcekit = {},
            },
          },
        },
      }
    '';
  };
}
