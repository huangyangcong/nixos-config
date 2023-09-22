{ inputs, config, pkgs, lib, ... }:
let
  sources = import ../../nix/sources.nix;
in
{
  home.file = {
    ".config/nvim" = {
      source = ./src;
      recursive = true;
    };
    ".config/nvim/lua/plugins/lang_extra.lua".text = ''
      return {
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
          "jose-elias-alvarez/null-ls.nvim",
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
                  "${pkgs.rust-analyzer}/bin/rust-analyzer}"
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
