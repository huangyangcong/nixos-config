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
                  "${pkgs.llvmPackages_16.clang-unwrapped}/bin/clangd",
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
