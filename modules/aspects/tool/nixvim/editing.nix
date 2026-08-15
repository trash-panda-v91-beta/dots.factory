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
      # Statusline mirrors starship jetpack layout & palette on a single line;
      # mode glyph lives at far left (herdr blocks OSC 12 so cursor-color
      # per mode is unreliable). Cursor shape/color still applied via guicursor
      # in default.nix — works outside herdr as a bonus.
      mini-statusline = {
        enable = true;
        settings = {
          use_icons = false;
          content.active.__raw = ''
            function()
              local bo, fn, b = vim.bo, vim.fn, vim.b

              -- Mode glyph (mirror starship character block: ◎/○/▼/■/□)
              local first = fn.mode():sub(1, 1)
              local glyph, mhl = "◎", "GeometryModeN"
              if     first == "i"                                                                                    then glyph, mhl = "○", "GeometryModeI"
              elseif first == "v" or first == "V" or first == "\22" or first == "s" or first == "S" or first == "\19" then glyph, mhl = "▼", "GeometryModeV"
              elseif first == "R"                                                                                    then glyph, mhl = "□", "GeometryModeR"
              elseif first == "c" or first == "r" or first == "!"                                                    then glyph, mhl = "■", "GeometryModeC"
              elseif first == "t"                                                                                    then glyph, mhl = "▪", "GeometryModeT"
              end

              -- Directory (starship [directory].repo_root_format equivalent).
              -- Cache repo root per buffer — vim.fs.root is a few filesystem stats
              -- but statusline redraws are frequent.
              local repo_root = b.geometry_repo_root
              if repo_root == nil then
                repo_root = vim.fs.root(0, ".git") or ""
                b.geometry_repo_root = repo_root
              end
              local repo_name = repo_root ~= "" and fn.fnamemodify(repo_root, ":t") or ""
              local basename  = fn.expand("%:t")
              if basename == "" then basename = "[No Name]" end

              -- Truncate subpath to last 2 components with "□ " prefix
              -- (matches starship truncation_length = 2, truncation_symbol = "□ ").
              local trunc, subpath = "", ""
              if repo_name ~= "" then
                local full = fn.expand("%:p")
                if full:sub(1, #repo_root) == repo_root then
                  local subdir = fn.fnamemodify(full:sub(#repo_root + 2), ":h")
                  if subdir ~= "" and subdir ~= "." then
                    local parts = vim.split(subdir, "/", { plain = true })
                    if #parts > 2 then
                      trunc = "□ "
                      subpath = "/" .. parts[#parts - 1] .. "/" .. parts[#parts]
                    else
                      subpath = "/" .. subdir
                    end
                  end
                end
              else
                local d = fn.fnamemodify(fn.expand("%:~:."), ":h")
                if d ~= "." then subpath = d .. "/" end
              end
              local readonly = bo.readonly and " ◈" or ""
              local modified = bo.modified and " ●" or ""
              local fname_leader = (repo_name ~= "" or subpath ~= "") and "/" or ""

              -- Git (from gitsigns; per-file hunks, not repo-wide file states).
              local branch  = b.gitsigns_head or ""
              local d       = b.gitsigns_status_dict or {}
              local added, changed, removed = d.added or 0, d.changed or 0, d.removed or 0
              local br      = #branch > 40 and (branch:sub(1, 40) .. "⋯") or branch
              local has_dirty = (added + changed + removed) > 0

              -- Diagnostics (O(1) via vim.diagnostic.count)
              local dc = vim.diagnostic.count(0) or {}
              local errs, warns = dc[vim.diagnostic.severity.ERROR] or 0, dc[vim.diagnostic.severity.WARN] or 0

              local ft   = bo.filetype
              local time = fn.strftime("%R")

              -- Filetype → jetpack-style glyph + color category.
              local FT = {
                rust            = { "⊃",  "GeometryLangRed"    },
                ruby            = { "◆",  "GeometryLangRed"    },
                swift           = { "◁",  "GeometryLangRed"    },
                python          = { "⌊",  "GeometryLangYellow" },
                lua             = { "⨀",  "GeometryLangYellow" },
                javascript      = { "◫", "GeometryLangGreen"  },
                typescript      = { "◫", "GeometryLangGreen"  },
                javascriptreact = { "◫", "GeometryLangGreen"  },
                typescriptreact = { "◫", "GeometryLangGreen"  },
                c               = { "ℂ",  "GeometryLangBlue"   },
                cpp             = { "ℂ",  "GeometryLangBlue"   },
                dart            = { "◁",  "GeometryLangBlue"   },
                nix             = { "✶",  "GeometryLangBlue"   },
                dockerfile      = { "◧",  "GeometryLangBlue"   },
                go              = { "∩",  "GeometryLangBlue"   },
                haskell         = { "❯L", "GeometryLangPurple" },
                julia           = { "◎",  "GeometryLangPurple" },
                elixir          = { "△",  "GeometryLangPurple" },
                markdown        = { "≡",  "GeometryFiletype"   },
                json            = { "◇",  "GeometryFiletype"   },
                yaml            = { "≣",  "GeometryFiletype"   },
                toml            = { "≡",  "GeometryFiletype"   },
                sh              = { "▶",  "GeometryFiletype"   },
                bash            = { "▶",  "GeometryFiletype"   },
                zsh             = { "▶",  "GeometryFiletype"   },
                fish            = { "▶",  "GeometryFiletype"   },
                nu              = { "▶",  "GeometryFiletype"   },
                vim             = { "◐",  "GeometryFiletype"   },
                html            = { "◈",  "GeometryFiletype"   },
                css             = { "◐",  "GeometryFiletype"   },
                scss            = { "◐",  "GeometryFiletype"   },
                make            = { "▤",  "GeometryFiletype"   },
                sql             = { "▦",  "GeometryFiletype"   },
              }

              -- Left: {mode}  {□ ?}{repo_root bold}{subpath italic}{/basename italic}{readonly}{modified}
              local left = string.format(
                "%%#%s# %s  %%#GeometryTruncBox#%s%%#GeometryRepoRoot#%s%%#GeometryPath#%s%s%%#GeometryReadOnly#%s%%#GeometryModified#%s",
                mhl, glyph, trunc, repo_name, subpath, fname_leader .. basename, readonly, modified
              )

              -- Right (touch branch to status bracket like starship;
              -- git_metrics after the bracket).
              local right = {}
              if branch ~= "" then
                local piece = string.format("%%#GeometryBranchSym#△ %%#GeometryBranch#%s", br)
                if has_dirty then
                  piece = piece .. "%#GeometryStatusBracket#⎪"
                  if changed > 0 or added > 0 then piece = piece .. "%#GeometryStatusMod#●◦" end
                  if removed > 0                then piece = piece .. "%#GeometryStatusDel#✕"    end
                  piece = piece .. "%#GeometryStatusBracket#⎥"
                end
                right[#right+1] = piece
              end
              if added   > 0 then right[#right+1] = string.format("%%#GeometryDiffAdd#▴%d",  added) end
              if removed > 0 then right[#right+1] = string.format("%%#GeometryDiffDel#▿%d",  removed) end
              if errs    > 0 then right[#right+1] = string.format("%%#GeometryDiagErr#✕%d",  errs) end
              if warns   > 0 then right[#right+1] = string.format("%%#GeometryDiagWarn#⚠%d", warns) end
              if ft     ~= "" then
                local entry = FT[ft]
                if entry then
                  right[#right+1] = string.format("%%#%s#%s", entry[2], entry[1])
                else
                  right[#right+1] = string.format("%%#GeometryFiletype#%s", ft)
                end
              end
              right[#right+1] = "%#GeometryLocation#L%l:%v"
              right[#right+1] = string.format("%%#GeometryTime#%s", time)

              return left .. "%<%=" .. table.concat(right, " ") .. " "
            end
          '';
          content.inactive.__raw = ''
            function()
              return "%#MiniStatuslineInactive# %f%m%r "
            end
          '';
        };
        luaConfig.post = ''
          -- Live clock: repaint statusline every 30s so time doesn't stale on idle.
          local t = vim.uv.new_timer()
          if t then t:start(30000, 30000, vim.schedule_wrap(function()
            if vim.api.nvim_get_mode().mode ~= "c" then vim.cmd("redrawstatus") end
          end)) end
        '';
      };
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

      -- === Geometry / jetpack integrations ===================================

      -- Fold text: closed folds render as "◐ +N ───── <first line>"
      _G.GeometryFoldText = function()
        local n = vim.v.foldend - vim.v.foldstart + 1
        local first = vim.fn.getline(vim.v.foldstart):gsub("^\\s+", "")
        return string.format("◐ +%d ─ %s", n, first)
      end
      vim.opt.foldtext = "v:lua.GeometryFoldText()"

      -- Winbar breadcrumb: mirrors starship [directory] grammar.
      --   ⌂  ⌈ dots.factory  tool/nixvim  editing.nix
      _G.GeometryWinbar = function()
        local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
        if vim.bo[buf].buftype ~= "" then return "" end
        local basename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
        if basename == "" then return "" end

        local repo_root = vim.b[buf].geometry_repo_root
        if repo_root == nil then
          repo_root = vim.fs.root(buf, ".git") or ""
          vim.b[buf].geometry_repo_root = repo_root
        end

        local full = vim.api.nvim_buf_get_name(buf)
        local parts = {}
        if repo_root ~= "" and full:sub(1, #repo_root) == repo_root then
          parts[#parts+1] = "%#GeometryWinbarHome#⌂ "
          parts[#parts+1] = "%#GeometryWinbarSep#⌈ "
          parts[#parts+1] = "%#GeometryWinbarRoot#" .. vim.fn.fnamemodify(repo_root, ":t")
          local sub = vim.fn.fnamemodify(full:sub(#repo_root + 2), ":h")
          if sub ~= "" and sub ~= "." then
            parts[#parts+1] = "  %#GeometryWinbarSep#›  %#GeometryWinbarPath#" .. sub
          end
          parts[#parts+1] = "  %#GeometryWinbarSep#›  %#GeometryWinbarFile#" .. basename
        else
          parts[#parts+1] = "%#GeometryWinbarFile#" .. basename
        end
        return " " .. table.concat(parts, "")
      end
      vim.opt.winbar = "%!v:lua.GeometryWinbar()"

      -- Sign-column mode dot: colored ◎ on the current line, tinted per mode.
      -- Compensates for terminals (herdr) that block OSC 12 cursor-color changes.
      local ns = vim.api.nvim_create_namespace("geometry_mode_dot")
      local mode_sign_hl = {
        n = "GeometryModeN", i = "GeometryModeI", v = "GeometryModeV",
        V = "GeometryModeV", ["\22"] = "GeometryModeV",
        s = "GeometryModeV", S = "GeometryModeV", ["\19"] = "GeometryModeV",
        R = "GeometryModeR", c = "GeometryModeC", r = "GeometryModeC",
        ["!"] = "GeometryModeC", t = "GeometryModeT",
      }
      local function paint_mode_dot()
        local buf = vim.api.nvim_get_current_buf()
        if not vim.api.nvim_buf_is_valid(buf) then return end
        if vim.bo[buf].buftype ~= "" then
          pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)
          return
        end
        local hl = mode_sign_hl[vim.fn.mode():sub(1, 1)] or "GeometryModeN"
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)
        pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, 0, {
          sign_text = "◎",
          sign_hl_group = hl,
          priority = 100,
        })
      end
      vim.api.nvim_create_autocmd({ "ModeChanged", "CursorMoved", "CursorMovedI", "BufEnter" }, {
        callback = vim.schedule_wrap(paint_mode_dot),
      })
    '';
  };
}
