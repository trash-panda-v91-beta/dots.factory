# Editing - treesitter, lz-n, auto-save, conform-nvim, mini.*, koda, render-markdown, codediff
# codediff replaces diffview (git diff + history)
{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._.editing ];
  dots.tool._.nixvim._.editing.homeManager = { pkgs, lib, ... }: {
    programs.nixvim.plugins = {
      # Lazy loading
      lz-n.enable = true;

      # Treesitter
      treesitter = {
        enable = true;
        folding.enable = true;
        highlight = {
          enable = true;
          # Bail on files larger than 1 MB - stops treesitter freezing on
          # minified JS/JSON. Replaces snacks.bigfile.
          disable.__raw = ''
            function(_, buf)
              local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > 1024 * 1024 then return true end
            end
          '';
        };
        indent.enable = true;
        nixvimInjections = true;
        # Exclude angular grammar - upstream hash is broken in nixpkgs
        grammarPackages = lib.filter (
          g: !(lib.hasSuffix "-angular" (g.pname or ""))
        ) pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
      };

      # Auto-save
      auto-save.enable = true;

      # Formatting
      conform-nvim = {
        enable = true;
        lazyLoad.settings = {
          cmd = [ "ConformInfo" ];
          event = [ "BufWritePre" ];
        };
        luaConfig.pre = "local slow_format_filetypes = {}";
        settings = {
          default_format_opts.lsp_format = "fallback";
          format_on_save = ''
            function(bufnr)
              if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
              if slow_format_filetypes[vim.bo[bufnr].filetype] then return end
              local bufname = vim.api.nvim_buf_get_name(bufnr)
              if bufname:match("/node_modules/") or bufname:match("/.direnv/") then return end
              local function on_format(err)
                if err and err:match("timeout$") then slow_format_filetypes[vim.bo[bufnr].filetype] = true end
              end
              return { timeout_ms = 200, lsp_fallback = true }, on_format
            end
          '';
          format_after_save = ''
            function(bufnr)
              if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
              if not slow_format_filetypes[vim.bo[bufnr].filetype] then return end
              return { lsp_fallback = true }
            end
          '';
          formatters_by_ft = {
            bash = [
              "shellcheck"
              "shellharden"
              "shfmt"
            ];
            css = [ "prettierd" ];
            javascript = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "biome";
              timeout_ms = 2000;
              stop_after_first = true;
            };
            json = [ "biome-check" ];
            html = [ "prettierd" ];
            just = [ "just" ];
            lua = [ "stylua" ];
            nix = [
              "nixfmt"
              "injected"
            ];
            python = [
              "ruff_fix"
              "ruff_format"
              "ruff_organize_imports"
            ];
            sql = [ "sqlfluff" ];
            rust = [ "rustfmt" ];
            sh = [
              "shellcheck"
              "shellharden"
              "shfmt"
            ];
            swift = [ "swift_format" ];
            typescript = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "biome";
              timeout_ms = 2000;
              stop_after_first = true;
            };
            xml = [
              "xmlformat"
              "xmllint"
            ];
            yaml = [ "yamlfmt" ];
          };
          formatters = {
            biome = {
              command = pkgs.lib.getExe pkgs.biome;
              env.BIOME_CONFIG_PATH = pkgs.writeTextFile {
                name = "biome.json";
                text = pkgs.lib.generators.toJSON { } {
                  "$schema" = "${pkgs.biome}/node_modules/@biomejs/biome/configuration_schema.json";
                  formatter.useEditorconfig = true;
                };
              };
            };
            jq.command = pkgs.lib.getExe pkgs.jq;
            just.command = pkgs.lib.getExe pkgs.just;
            nixfmt.command = pkgs.lib.getExe pkgs.nixfmt;
            prettierd.command = pkgs.lib.getExe pkgs.prettierd;
            ruff.command = pkgs.lib.getExe pkgs.ruff;
            rustfmt.command = pkgs.lib.getExe pkgs.rustfmt;
            shellcheck.command = pkgs.lib.getExe pkgs.shellcheck;
            shellharden.command = pkgs.lib.getExe pkgs.shellharden;
            shfmt.command = pkgs.lib.getExe pkgs.shfmt;
            sqlfluff.command = pkgs.lib.getExe pkgs.sqlfluff;
            stylua.command = pkgs.lib.getExe pkgs.stylua;
            swift_format.command = pkgs.lib.getExe pkgs.swift-format;
            xmlformat.command = pkgs.lib.getExe pkgs.xmlformat;
            yamlfmt.command = pkgs.lib.getExe pkgs.yamlfmt;
            injected.ignore_errors = false;
          };
        };
      };

      # Mini modules
      mini-ai = {
        enable = true;
        settings = {
          search_method = "cover";
          custom_textobjects.__raw = ''
            {
              B = require('mini.extra').gen_ai_spec.buffer(),
              F = require('mini.ai').gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
            }
          '';
        };
      };

      mini-icons = {
        enable = true;
        mockDevIcons = true;
        settings = {
          use_file_extension.__raw = ''
            function(ext, _)
              local ext3 = { scm = true, txt = true, yml = true }
              local ext4 = { json = true, yaml = true }
              return not (ext3[ext:sub(-3)] or ext4[ext:sub(-4)])
            end
          '';
        };
        luaConfig.post = ''
          MiniIcons.tweak_lsp_kind()
        '';
      };

      # Statusline + tabline (replaces lualine)
      mini-statusline.enable = true;
      mini-tabline.enable = true;

      # Completion (replaces blink-cmp)
      mini-completion = {
        enable = true;
        settings = {
          delay.completion = 100;
          lsp_completion = {
            source_func = "omnifunc";
            auto_setup = false;
            process_items.__raw = ''
              function(items, base)
                local opts = { kind_priority = { Text = -1, Snippet = 99 } }
                return MiniCompletion.default_process_items(items, base, opts)
              end
            '';
          };
          window = {
            info.border = "single";
            signature.border = "single";
          };
        };
        luaConfig.post = ''
          -- Set omnifunc via LspAttach (matches MiniMax pattern)
          vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(ev)
              vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
            end,
          })
          -- Advertise completion capabilities to LSP servers
          vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })
        '';
      };

      # Tab / Shift-Tab / CR / BS for pmenu navigation with mini.completion
      # (mini.keymap not exposed as individual nixvim plugin - use bundle)

      # Notifications (replaces snacks.notifier)
      mini-notify = {
        enable = true;
        settings = {
          lsp_progress.enable = true;
          window.config.border = "single";
        };
        luaConfig.post = ''vim.notify = MiniNotify.make_notify()'';
      };

      # Buffer deletion keeping window layout (replaces snacks.bufdelete)
      mini-bufremove.enable = true;

      # Highlight word under cursor
      mini-cursorword.enable = true;

      # Autopairs (also in cmdline)
      mini-pairs = {
        enable = true;
        settings.modes.command = true;
      };

      # Extra options + <C-hjkl> window nav + \-toggles
      mini-basics = {
        enable = true;
        settings = {
          options.basic = false;
          mappings = {
            windows = true;
            move_with_alt = true;
          };
        };
      };

      # gc / gcc commenting
      mini-comment.enable = true;

      # Motion
      mini-jump.enable = true;
      mini-jump2d.enable = true;

      # <M-hjkl> to move lines/selections
      mini-move.enable = true;

      # gr replace, gx exchange, gs sort, gm multiply, g= evaluate
      mini-operators = {
        enable = true;
        luaConfig.post = ''
          -- Swap adjacent function arguments (relies on mini.ai's `a` textobject)
          vim.keymap.set('n', '(', 'gxiagxila', { remap = true, desc = 'Swap arg left' })
          vim.keymap.set('n', ')', 'gxiagxina', { remap = true, desc = 'Swap arg right' })
        '';
      };

      mini-align.enable = true;
      mini-bracketed.enable = true;
      mini-splitjoin.enable = true;
      mini-trailspace.enable = true;

      # TODO/FIXME/NOTE/HACK + hex colour highlighting
      mini-hipatterns = {
        enable = true;
        settings.highlighters.__raw = ''
          {
            fixme = require('mini.extra').gen_highlighter.words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
            hack  = require('mini.extra').gen_highlighter.words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
            todo  = require('mini.extra').gen_highlighter.words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
            note  = require('mini.extra').gen_highlighter.words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),
            hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
          }
        '';
      };

      # Cmdline autocomplete + autocorrect - via mini.modules bundle below

      # vim.ui.input replacement - via mini.modules bundle below

      # Auto root + restore cursor + terminal bg sync
      mini-misc = {
        enable = true;
        luaConfig.post = ''
          MiniMisc.setup_auto_root()
          MiniMisc.setup_restore_cursor()
          MiniMisc.setup_termbg_sync()
        '';
      };

      # Frecency (visits picker via mini.extra)
      mini-visits.enable = true;

      # Session management
      mini-sessions.enable = true;

      # Which-key replacement
      mini-clue = {
        enable = true;
        settings = {
          window.config.border = "single";
          triggers = [
            { mode = "n"; keys = "<Leader>"; }
            { mode = "x"; keys = "<Leader>"; }
            { mode = "n"; keys = "<LocalLeader>"; }
            { mode = "x"; keys = "<LocalLeader>"; }
            { mode = "n"; keys = "\\"; }
            { mode = "n"; keys = "["; }
            { mode = "x"; keys = "["; }
            { mode = "n"; keys = "]"; }
            { mode = "x"; keys = "]"; }
            { mode = "i"; keys = "<C-x>"; }
            { mode = "n"; keys = "g"; }
            { mode = "x"; keys = "g"; }
            { mode = "n"; keys = "'"; }
            { mode = "x"; keys = "'"; }
            { mode = "n"; keys = "`"; }
            { mode = "x"; keys = "`"; }
            { mode = "n"; keys = "\""; }
            { mode = "x"; keys = "\""; }
            { mode = "i"; keys = "<C-r>"; }
            { mode = "c"; keys = "<C-r>"; }
            { mode = "n"; keys = "<C-w>"; }
            { mode = "n"; keys = "s"; }
            { mode = "x"; keys = "s"; }
            { mode = "n"; keys = "z"; }
            { mode = "x"; keys = "z"; }
          ];
          clues.__raw = ''
            {
              require('mini.clue').gen_clues.builtin_completion(),
              require('mini.clue').gen_clues.g(),
              require('mini.clue').gen_clues.marks(),
              require('mini.clue').gen_clues.registers(),
              require('mini.clue').gen_clues.square_brackets(),
              require('mini.clue').gen_clues.windows({ submode_resize = true }),
              require('mini.clue').gen_clues.z(),
              { mode = 'n', keys = '<Leader>b', desc = '+Buffers' },
              { mode = 'n', keys = '<Leader>c', desc = '+Code' },
              { mode = 'x', keys = '<Leader>c', desc = '+Code' },
              { mode = 'n', keys = '<Leader>d', desc = '+Debug' },
              { mode = 'n', keys = '<Leader>f', desc = '+Find' },
              { mode = 'n', keys = '<Leader>g', desc = '+Git' },
              { mode = 'x', keys = '<Leader>g', desc = '+Git' },
              { mode = 'n', keys = '<Leader>l', desc = '+LSP' },
              { mode = 'n', keys = '<Leader>n', desc = '+Notes' },
              { mode = 'n', keys = '<Leader>o', desc = '+Octo' },
              { mode = 'n', keys = '<Leader>p', desc = '+Pi' },
              { mode = 'x', keys = '<Leader>p', desc = '+Pi' },
              { mode = 'n', keys = '<Leader>q', desc = '+Quit/Session' },
              { mode = 'n', keys = '<Leader>r', desc = '+Replace/Refactor' },
              { mode = 'n', keys = '<Leader>t', desc = '+Terminal/Test' },
              { mode = 'n', keys = '<Leader>u', desc = '+UI' },
              { mode = 'n', keys = '<Leader>un', desc = '+Notifications' },
              { mode = 'n', keys = '<Leader>uc', desc = '+Completion' },
              { mode = 'n', keys = '<Leader>w', desc = '+Windows' },
              { mode = 'n', keys = '<Leader>x', desc = '+Diagnostics/Quickfix' },
              { mode = 'n', keys = '<Leader>y', desc = '+Yank' },
              { mode = 'x', keys = '<Leader>y', desc = '+Yank' },
            }
          '';
        };
      };

      mini = {
        enable = true;
        modules = {
          indentscope = { };
          snippets.snippets.__unkeyed-2.__raw = ''require("mini.snippets").gen_loader.from_lang()'';
          # Newer modules without individual nixvim plugin options
          cmdline = { };
          input = { };
          keymap = { };
        };
        luaConfig.post = ''
          -- mini.keymap: Tab/S-Tab/CR/BS for pmenu (mini.completion UX)
          MiniKeymap.map_multistep('i', '<Tab>',   { 'pmenu_next' })
          MiniKeymap.map_multistep('i', '<S-Tab>', { 'pmenu_prev' })
          MiniKeymap.map_multistep('i', '<CR>',    { 'pmenu_accept', 'minipairs_cr' })
          MiniKeymap.map_multistep('i', '<BS>',    { 'minipairs_bs' })
        '';
      };

      mini-surround.enable = true;

      # Render markdown (obsidian, octo)
      render-markdown = {
        enable = true;
        lazyLoad.settings.ft = [
          "markdown"
          "octo"
        ];
        settings = {
          completions.lsp.enabled = true;
          file_types = [
            "markdown"
            "octo"
          ];
          render_modes = true;
        };
      };

      # Codediff
      # Inline diagnostics (rachartier/tiny-inline-diagnostic.nvim)
      # Loads on DeferredUIEnter (before first LspAttach) so its own
      # LspAttach autocmd fires for every attached client
      tiny-inline-diagnostic = {
        enable = true;
        lazyLoad.settings.event = "DeferredUIEnter";
        settings = {
          preset = "modern";
          options = {
            show_source = {
              enabled = true;
              if_many = false;
            };
            multilines.enabled = true;
            show_all_diags_on_cursorline = false;
            enable_on_insert = false;
            virt_texts.priority = 2048;
          };
        };
      };

      codediff = {
        enable = true;
        settings.keymaps = {
          explorer = {
            select = "<CR>";
            hover = "K";
            refresh = "R";
          };
          view = {
            next_hunk = "]c";
            prev_hunk = "[c";
            next_file = "]f";
            prev_file = "[f";
          };
        };
      };
    };

    # Snippets file
    programs.nixvim.extraFiles."snippets/nix.json".source = ./snippets/nix.json;

    # Codediff keymaps
    programs.nixvim.keymaps = [
      {
        mode = [ "n" ];
        key = "<leader>gd";
        action = "<cmd>CodeDiff<cr>";
        options.desc = "Open CodeDiff";
      }
      {
        mode = [ "n" ];
        key = "<leader>gh";
        action = "<cmd>CodeDiff history<cr>";
        options.desc = "CodeDiff History";
      }
      {
        mode = [ "n" ];
        key = "<leader>gH";
        action = "<cmd>CodeDiff history %<cr>";
        options.desc = "CodeDiff Current File History";
      }
    ];

    # Lint
    programs.nixvim.plugins.lint = {
      enable = true;
      lazyLoad.settings.event = [ "BufReadPost" ];
      lintersByFt = {
        "yaml.ghaction" = [
          "actionlint"
          "zizmor"
          "yamllint"
        ];
        "yaml.cloudformation" = [
          "cfn_lint"
          "yamllint"
        ];
        dockerfile = [ "hadolint" ];
        yaml = [ "yamllint" ];
      };
      linters = {
        actionlint = {
          cmd = pkgs.lib.getExe pkgs.actionlint;
          args = [
            "-format"
            "{{json .}}"
            "-stdin-filename"
            { __raw = "function() return vim.api.nvim_buf_get_name(0) end"; }
            "-"
          ];
        };
        cfn_lint.cmd = pkgs.lib.getExe pkgs.python3Packages.cfn-lint;
        hadolint.cmd = pkgs.lib.getExe pkgs.hadolint;
        yamllint.cmd = pkgs.lib.getExe pkgs.yamllint;
        zizmor.cmd = pkgs.lib.getExe pkgs.zizmor;
      };
      autoCmd = {
        event = [
          "BufEnter"
          "BufWritePost"
          "InsertLeave"
        ];
        callback.__raw = ''
          function()
            local ok, lint = pcall(require, "lint")
            if not ok then return end
            local filetype = vim.bo.filetype
            if vim.bo.buftype ~= "" then return end
            local skip_filetypes = { "gitcommit", "gitrebase", "help", "qf" }
            if vim.tbl_contains(skip_filetypes, filetype) then return end
            if filetype == "yaml.ghaction" then
              local repo_root = vim.fs.root(0, ".git")
              if repo_root then lint.try_lint(nil, { cwd = repo_root }); return end
            end
            lint.try_lint()
          end
        '';
      };
    };

    programs.nixvim.filetype.pattern = {
      ".*/%.github/workflows/.*%.ya?ml" = "yaml.ghaction";
      ".*cloudformation.*%.ya?ml" = "yaml.cloudformation";
      ".*%-stack%.ya?ml" = "yaml.cloudformation";
      ".*template%.ya?ml" = "yaml.cloudformation";
    };

    # Koda
    programs.nixvim.extraPlugins = [
      pkgs.local.koda-nvim
      pkgs.local.tiny-code-action-nvim
    ];
    programs.nixvim.extraConfigLua = ''
      require("koda").setup({ auto = false, cache = true, })

      -- Lazy-load tiny-code-action on first LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        once = true,
        callback = function()
          require("tiny-code-action").setup({
            backend = "vim",
            picker = {
              "buffer",
              opts = {
                hotkeys = true,
                hotkeys_mode = "sequential",
                auto_preview = false,
                auto_accept = false,
                position = "cursor",
                winborder = "single",
              },
            },
          })
        end,
      })
    '';
  };
}
