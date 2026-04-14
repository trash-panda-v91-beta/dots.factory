{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._.ui ];
  dots.nixvim._.ui.homeManager =
    { ... }:
    {
      programs.nixvim.plugins = {
        web-devicons.enable = true;

        tiny-glimmer-nvim = {
          enable = true;
          lazyLoad.settings.event = "DeferredUIEnter";
          settings = {
            transparency_color = "#151718";
            overwrite = {
              yank.enabled = true;
              paste.enable = true;
              undo.enabled = true;
              redo.enabled = true;
            };
          };
        };

        notify = {
          enable = true;
          lazyLoad.settings.event = "DeferredUIEnter";
        };

        noice = {
          enable = true;
          lazyLoad.settings.event = "DeferredUIEnter";
          settings = {
            cmdline.format = {
              cmdline = {
                pattern = "^:";
                icon = "";
                lang = "vim";
                opts.border.text.top = "Cmd";
              };
              search_down = {
                kind = "search";
                pattern = "^/";
                icon = " ";
                lang = "regex";
              };
              search_up = {
                kind = "search";
                pattern = "^%?";
                icon = " ";
                lang = "regex";
              };
              filter = {
                pattern = "^:%s*!";
                icon = "";
                lang = "bash";
                opts.border.text.top = "Bash";
              };
              lua = {
                pattern = "^:%s*lua%s+";
                icon = "";
                lang = "lua";
              };
              help = {
                pattern = "^:%s*he?l?p?%s+";
                icon = "󰋖";
              };
              input = { };
            };
            messages = {
              view = "notify";
              view_error = "notify";
              view_warn = "notify";
            };
            lsp = {
              override = {
                "vim.lsp.util.convert_input_to_markdown_lines" = true;
                "vim.lsp.util.stylize_markdown" = true;
                "cmp.entry.get_documentation" = true;
              };
              progress.enabled = true;
              signature.enabled = true;
            };
            popupmenu.backend = "nui";
            presets = {
              bottom_search = false;
              command_palette = true;
              long_message_to_split = true;
              inc_rename = true;
              lsp_doc_border = true;
            };
            routes = [
              {
                filter = {
                  event = "msg_show";
                  kind = "search_count";
                };
                opts.skip = true;
              }
            ];
            views = {
              cmdline_popup.border.style = "single";
              confirm.border = {
                style = "single";
                text.top = "";
              };
              notify = {
                border.style = "rounded";
                position = {
                  row = 2;
                  col = "100%";
                };
                size = {
                  width = "auto";
                  max_width = 60;
                };
              };
            };
          };
        };

        lualine.enable = true;

        which-key = {
          enable = true;
          settings = {
            preset = "helix";
            delay = 300;
            show_help = false;
            show_keys = false;
            notify = false;
            layout = {
              spacing = 3;
              align = "center";
            };
            triggers = [
              {
                __unkeyed-1 = "<auto>";
                mode = "nxso";
              }
              {
                __unkeyed-1 = "<localleader>";
                mode = "nxso";
              }
            ];
            icons = {
              rules = false;
              breadcrumb = " ";
              separator = "➜";
              group = "";
              mappings = false;
            };
            spec = [
              {
                __unkeyed-1 = "<leader>s";
                group = "Sidekick";
                icon = "🤖";
                mode = [
                  "n"
                  "v"
                ];
              }
              {
                __unkeyed-1 = "<leader>b";
                group = "Buffers";
                icon = "󰓩";
              }
              {
                __unkeyed-1 = "<leader>c";
                group = "Code";
                icon = "";
                mode = [
                  "n"
                  "v"
                ];
              }
              {
                __unkeyed-1 = "<leader>d";
                group = "Debug";
                icon = "";
              }
              {
                __unkeyed-1 = "<leader>f";
                group = "Find";
                icon = "";
              }
              {
                __unkeyed-1 = "<leader>g";
                group = "Git";
                icon = "";
                mode = [
                  "n"
                  "v"
                ];
              }
              {
                __unkeyed-1 = "<leader>gd";
                group = "Diff";
                icon = "";
              }
              {
                __unkeyed-1 = "<leader>gh";
                group = "Hunk";
                icon = "";
              }
              {
                __unkeyed-1 = "<leader>l";
                group = "LSP";
                icon = "💡";
              }
              {
                __unkeyed-1 = "<leader>n";
                group = "Notes";
                icon = "";
              }
              {
                __unkeyed-1 = "<leader>ob";
                desc = "Render base embed";
              }
              {
                __unkeyed-1 = "<leader>oo";
                desc = "Open file from base embed";
              }
              {
                __unkeyed-1 = "<leader>un";
                group = "Notifications";
                icon = "";
              }
              {
                __unkeyed-1 = "<leader>q";
                group = "Quit/Session";
                icon = "󰗼";
              }
              {
                __unkeyed-1 = "<leader>r";
                group = "Replace/Refactor";
                icon = "🔄";
              }
              {
                __unkeyed-1 = "<leader>t";
                group = "Terminal/Test";
                icon = "";
              }
              {
                __unkeyed-1 = "<leader>u";
                group = "UI";
                icon = "󰙵";
              }
              {
                __unkeyed-1 = "<leader>w";
                group = "Windows";
                icon = "";
              }
              {
                __unkeyed-1 = "<leader>x";
                group = "Diagnostics/Quickfix";
                icon = "󱖫";
              }
              {
                __unkeyed-1 = "[";
                group = "Previous";
              }
              {
                __unkeyed-1 = "]";
                group = "Next";
              }
              {
                __unkeyed-1 = "g";
                group = "Goto";
              }
              {
                __unkeyed-1 = "gs";
                group = "Surround";
              }
            ];
            replace.desc = [
              [
                "<space>"
                "SPACE"
              ]
              [
                "<leader>"
                "SPACE"
              ]
              [
                "<[cC][rR]>"
                "RETURN"
              ]
              [
                "<[tT][aA][bB]>"
                "TAB"
              ]
              [
                "<[bB][sS]>"
                "BACKSPACE"
              ]
            ];
            win = {
              no_overlap = false;
              width = {
                min = 35;
                max = 35;
              };
              height.max = 120;
              border = "single";
            };
            sort = [
              "alphanum"
              "local"
              "order"
              "mod"
            ];
          };
        };
      };
    };
}
