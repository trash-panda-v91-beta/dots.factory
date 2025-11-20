{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.noice";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    plugins = {
      noice = {
        enable = true;

        lazyLoad.settings.event = "DeferredUIEnter";

        settings = {
          cmdline = {
            format = {
              cmdline = {
                pattern = "^:";
                icon = "";
                lang = "vim";
                opts = {
                  border = {
                    text = {
                      top = "Cmd";
                    };
                  };
                };
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
                opts = {
                  border = {
                    text = {
                      top = "Bash";
                    };
                  };
                };
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
          };

          # Route messages to notify
          messages = {
            view = "notify";
            view_error = "notify";
            view_warn = "notify";
          };

          # LSP UI enhancements
          lsp = {
            override = {
              "vim.lsp.util.convert_input_to_markdown_lines" = true;
              "vim.lsp.util.stylize_markdown" = true;
              "cmp.entry.get_documentation" = true;
            };

            progress.enabled = true;
            signature.enabled = true;
          };

          # Use nui backend for popupmenu
          popupmenu.backend = "nui";

          # Presets for common UI patterns
          presets = {
            bottom_search = false;
            command_palette = true;
            long_message_to_split = true;
            inc_rename = true;
            lsp_doc_border = true;
          };

          # Message routing and filtering
          routes = [
            # Skip search count messages
            {
              filter = {
                event = "msg_show";
                kind = "search_count";
              };
              opts = {
                skip = true;
              };
            }
          ];

          # View customization
          views = {
            cmdline_popup = {
              border = {
                style = "single";
              };
            };

            confirm = {
              border = {
                style = "single";
                text = {
                  top = "";
                };
              };
            };

            notify = {
              border = {
                style = "rounded";
              };
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

      # Notify is required for noice notifications
      notify = {
        enable = true;
        lazyLoad.settings.event = "DeferredUIEnter";
      };
    };
  };
}
