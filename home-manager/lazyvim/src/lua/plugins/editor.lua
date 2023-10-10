local Util = require("lazyvim.util")
local File = require("utils.file")
Util.root_patterns = { ".git" }

local find_files_command = { "rg", "--files", "--hidden", "-g", "!{node_modules,.git}" }

local function get_visual()
  local _, ls, cs = unpack(vim.fn.getpos("v"))
  local _, le, ce = unpack(vim.fn.getpos("."))
  return vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})
end

return {

  -- disable mini.bufremove
  { "echasnovski/mini.bufremove", enabled = false },

  -- use bdelete instead
  {
    "famiu/bufdelete.nvim",
    -- stylua: ignore
    config = function(_, opts)
      -- switches to Alpha dashboard when last buffer is closed
      local alpha_on_empty = vim.api.nvim_create_augroup("alpha_on_empty", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        pattern = "BDeletePost*",
        group = alpha_on_empty,
        callback = function(event)
          local fallback_name = vim.api.nvim_buf_get_name(event.buf)
          local fallback_ft = vim.api.nvim_buf_get_option(event.buf, "filetype")
          local fallback_on_empty = fallback_name == "" and fallback_ft == ""
          if fallback_on_empty then
            vim.cmd([[Neotree close]])
            vim.cmd("Alpha")
            vim.cmd(event.buf .. "bwipeout")
          end
        end,
      })
    end,
    keys = {
      { "<leader>bd", "<CMD>Bdelete<CR>", desc = "Delete Buffer" },
      { "<leader>bD", "<CMD>Bdelete!<CR>", desc = "Delete Buffer (Force)" },
    },
  },

  -- customize file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      commands = {
        copy_selector = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local filename = node.name
          local modify = vim.fn.fnamemodify

          local vals = {
            ["BASENAME"] = modify(filename, ":r"),
            ["EXTENSION"] = modify(filename, ":e"),
            ["FILENAME"] = filename,
            ["PATH (CWD)"] = modify(filepath, ":."),
            ["PATH (HOME)"] = modify(filepath, ":~"),
            ["PATH"] = filepath,
            ["URI"] = vim.uri_from_fname(filepath),
          }

          local options = vim.tbl_filter(function(val)
            return vals[val] ~= ""
          end, vim.tbl_keys(vals))
          if vim.tbl_isempty(options) then
            vim.notify("No values to copy", vim.log.levels.WARN)
            return
          end
          table.sort(options)
          vim.ui.select(options, {
            prompt = "Choose to copy to clipboard:",
            format_item = function(item)
              return ("%s: %s"):format(item, vals[item])
            end,
          }, function(choice)
            local result = vals[choice]
            if result then
              vim.notify(("Copied: `%s`"):format(result))
              vim.fn.setreg("+", result)
            end
          end)
        end,
      },
      window = {
        mappings = {
          Y = "copy_selector",
        },
      },
      close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
      filesystem = {
        follow_current_file = {
          enabled = true, -- This will find and focus the file in the active buffer every
        },
        -- time the current file is changed while the tree is open.
        group_empty_dirs = true, -- when true, empty folders will be grouped together
        hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
      },
    },
  },

  -- ====for live_grep raw====:
  -- for rg usage: reference: https://segmentfault.com/a/1190000016170184
  -- -i ignore case
  -- -s 大小写敏感
  -- -w match word
  -- -e 正则表达式匹配
  -- -v 反转匹配
  -- -g 通配符文件或文件夹，可以用!来取反
  -- -F fixed-string 原意字符串，类似python的 r'xxx'

  -- examples:
  -- command	Description
  -- rg image utils.py	Search in a single file utils.py
  -- rg image src/	Search in dir src/ recursively
  -- rg image	Search image in current dir recursively
  -- rg '^We' test.txt	Regex searching support (lines starting with We)
  -- rg -i image	Search image and ignore case (case-insensitive search)
  -- rg -s image	Smart case search
  -- rg -F '(test)'	Search literally, i.e., without using regular expression
  -- rg image -g '*.py'	File globing (search in certain files), can be used multiple times
  -- rg image -g '!*.py'	Negative file globing (do not search in certain files)
  -- rg image --type py or rg image -tpy1	Search image in Python file
  -- rg image -Tpy	Do not search image in Python file type
  -- rg -l image	Only show files containing image (Do not show the lines)
  -- rg --files-without-match image	Show files not containing image
  -- rg -v image	Inverse search (search files not containing image)
  -- rg -w image	Search complete word
  -- rg --count	Show the number of matching lines in a file
  -- rg --count-matches	Show the number of matchings in a file
  -- rg neovim --stats	Show the searching stat (how many matches, how many files searched etc.)

  -- ====for fzf search=====
  -- Token	Match type	Description
  -- sbtrkt	fuzzy-match	Items that match sbtrkt
  -- 'wild	exact-match (quoted)	Items that include wild
  -- ^music	prefix-exact-match	Items that start with music
  -- .mp3$	suffix-exact-match	Items that end with .mp3
  -- !fire	inverse-exact-match	Items that do not include fire
  -- !^music	inverse-prefix-exact-match	Items that do not start with music
  -- !.mp3$	inverse-suffix-exact-match	Items that do not end with .mp3

  -- A single bar character term acts as an OR operator.
  -- For example, the following query matches entries that start with core and end with either go, rb, or py.
  -- ^core go$ | rb$ | py$

  -- customize telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-dap.nvim" },
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "debugloop/telescope-undo.nvim" },
      { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
    keys = {
      {
        "<leader>fs",
        function()
          require("telescope").extensions.live_grep_args.live_grep_args({
            -- default_text='-g * ' .. vim.fn.expand('<cword>')
            default_text = "-g *" .. File.get_cur_file_extension() .. " ",
          })
        end,
        desc = "Find String",
      },
      {
        "<leader>fs",
        function()
          require("telescope").extensions.live_grep_args.live_grep_args({
            default_text = "-g *" .. File.get_cur_file_extension() .. " " .. get_visual()[1],
          })
        end,
        desc = "Find String",
        mode = { "x" },
      },
      {
        "<leader><space>",
        Util.telescope("find_files"),
        desc = "Find Files (root dir)",
      },
      {
        "<leader>/",
        Util.telescope("live_grep", { find_command = find_files_command }),
        desc = "Grep (root dir)",
      },
      {
        "<leader>ff",
        Util.telescope("find_files", { find_command = find_files_command }),
        desc = "Find Files (root dir)",
      },
      {
        "<leader>fF",
        Util.telescope("find_files", { cwd = false, find_command = find_files_command }),
        desc = "Find Files (re. Git root)",
      },
    },
    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        layout_strategy = "horizontal", -- horizontal vertical
        layout_config = {
          vertical = {
            preview_cutoff = 0.2,
            preview_height = 0.4,
          },
          height = 0.9,
          width = 0.9,
        },
        file_ignore_patterns = {
          "target/*",
          "node_modules/*",
          "dist/*",
          "build/*",
          "codegen/*",
          "generated/*",
          "tmp/*",
          "^.git/*",
          "^.yarn/*",
          "^.gradle/*",
        },
        mappings = {
          i = {
            ["<C-j>"] = function(...)
              return require("telescope.actions").move_selection_next(...)
            end,
            ["<C-k>"] = function(...)
              return require("telescope.actions").move_selection_previous(...)
            end,
            ["<C-p>"] = function(...)
              return require("telescope.actions.layout").toggle_preview(...)
            end,
          },
          n = {
            ["j"] = function(...)
              return require("telescope.actions").move_selection_next(...)
            end,
            ["k"] = function(...)
              return require("telescope.actions").move_selection_previous(...)
            end,
            ["gg"] = function(...)
              return require("telescope.actions").move_to_top(...)
            end,
            ["G"] = function(...)
              return require("telescope.actions").move_to_bottom(...)
            end,
            ["<C-p>"] = function(...)
              return require("telescope.actions.layout").toggle_preview(...)
            end,
          },
        },
      },
      extensions = {
        undo = {
          use_delta = true,
          side_by_side = true,
          layout_strategy = "vertical",
          layout_config = {
            preview_height = 0.4,
          },
        },
        live_grep_args = {
          vimgrep_arguments = find_command,
          auto_quoting = true, -- enable/disable auto-quoting
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("dap")
      telescope.load_extension("fzf")
      telescope.load_extension("undo")
      telescope.load_extension("live_grep_args")
    end,
  },

  -- git blame
  {
    "f-person/git-blame.nvim",
    event = "BufReadPre",
  },

  -- git conflict
  {
    "akinsho/git-conflict.nvim",
    event = "BufReadPre",
    opts = {},
  },

  -- add symbols-outline
  -- {
  --   "simrat39/symbols-outline.nvim",
  --   cmd = "SymbolsOutline",
  --   keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
  --   opts = function(_, opts)
  --     local icons = require("lazyvim.config").icons
  --     require("symbols-outline").setup({
  --       symbols = {
  --         File = { icon = icons.kinds.File, hl = "TSURI" },
  --         Module = { icon = icons.kinds.Module, hl = "TSNamespace" },
  --         Namespace = { icon = icons.kinds.Namespace, hl = "TSNamespace" },
  --         Package = { icon = icons.kinds.Package, hl = "TSNamespace" },
  --         Class = { icon = icons.kinds.Class, hl = "TSType" },
  --         Method = { icon = icons.kinds.Method, hl = "TSMethod" },
  --         Property = { icon = icons.kinds.Property, hl = "TSMethod" },
  --         Field = { icon = icons.kinds.Field, hl = "TSField" },
  --         Constructor = { icon = icons.kinds.Constructor, hl = "TSConstructor" },
  --         Enum = { icon = icons.kinds.Enum, hl = "TSType" },
  --         Interface = { icon = icons.kinds.Interface, hl = "TSType" },
  --         Function = { icon = icons.kinds.Function, hl = "TSFunction" },
  --         Variable = { icon = icons.kinds.Variable, hl = "TSConstant" },
  --         Constant = { icon = icons.kinds.Constant, hl = "TSConstant" },
  --         String = { icon = icons.kinds.String, hl = "TSString" },
  --         Number = { icon = icons.kinds.Number, hl = "TSNumber" },
  --         Boolean = { icon = icons.kinds.Boolean, hl = "TSBoolean" },
  --         Array = { icon = icons.kinds.Array, hl = "TSConstant" },
  --         Object = { icon = icons.kinds.Object, hl = "TSType" },
  --         Key = { icon = icons.kinds.Key, hl = "TSType" },
  --         Null = { icon = icons.kinds.Null, hl = "TSType" },
  --         EnumMember = { icon = icons.kinds.EnumMember, hl = "TSField" },
  --         Struct = { icon = icons.kinds.Struct, hl = "TSType" },
  --         Event = { icon = icons.kinds.Event, hl = "TSType" },
  --         Operator = { icon = icons.kinds.Operator, hl = "TSOperator" },
  --         TypeParameter = { icon = icons.kinds.TypeParameter, hl = "TSParameter" }
  --       }
  --     })
  --   end
  -- },

  -- add zen-mode
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {},
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
  },

  -- translate
  {
    "voldikss/vim-translator",
    cmd = {
      "Translate",
      "TranslateV",
      "TranslateW",
      "TranslateWV",
      "TranslateR",
      "TranslateRV",
      "TranslateH",
      "TranslateL",
      "TranslateX",
    },
    config = function(_, opts)
      vim.g.translator_history_enable = true
    end,
    keys = {
      { "<leader>tlw", "<Plug>TranslateWV<cr>", desc = "Translate Current vision Word.", mode = { "v" } },
      { "<leader>tlw", "<Plug>TranslateW<cr>", desc = "Translate Current Word." },
    },
  },

  -- switch input method automatically depending on mode
  {
    "keaising/im-select.nvim",
    cond = jit.os == "Linux",
    event = "VeryLazy",
    opts = {},
  },
}
