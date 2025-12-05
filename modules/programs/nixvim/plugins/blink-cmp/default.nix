{
  delib,
  lib,
  ...
}:
let
  mkBlinkPlugin =
    {
      enable ? true,
      ...
    }@args:
    {
      inherit enable;
      lazyLoad.settings.event = [
        "InsertEnter"
        "CmdlineEnter"
      ];
    }
    // (builtins.removeAttrs args [ "enable" ]);
in
delib.module {
  name = "programs.nixvim.plugins.blink-cmp";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    plugins = {
      blink-ripgrep = mkBlinkPlugin { };
    };

    plugins.blink-cmp = {
      enable = true;

      lazyLoad.settings.event = [
        "InsertEnter"
        "CmdlineEnter"
      ];

      settings = {
        cmdline = {
          completion = {
            list.selection = {
              preselect = false;
            };
            menu.auto_show = true;
          };
          keymap = {
            preset = "enter";
            "<CR>" = [
              "accept_and_enter"
              "fallback"
            ];
          };
        };

        completion = {
          keyword = {
            range = "full";
          };

          trigger = {
            prefetch_on_insert = true;
            show_on_backspace = true;
            show_on_insert_on_trigger_character = true;
            show_in_snippet = true;
          };

          ghost_text.enabled = true;

          accept.auto_brackets = {
            override_brackets_for_filetypes = {
              lua = [
                "{"
                "}"
              ];
              nix = [
                "{"
                "}"
              ];
            };
          };

          documentation = {
            auto_show = false;
            auto_show_delay_ms = 200;
            window.border = "single";
          };

          list.selection = {
            auto_insert = true;
            preselect = true;
          };

          menu = {
            border = "single";
            min_width = 35;
            auto_show = true;
            auto_show_delay_ms = 300;
            direction_priority = [
              "n"
              "s"
            ];
            draw = {
              snippet_indicator = "◦";
              treesitter = [ "lsp" ];
              columns.__raw = ''
                function()
                  return {
                    { "kind_icon" },
                    { "label", "label_description", gap = 1 }
                  }
                end
              '';
              components = {
                item_idx = {
                  text.__raw = ''
                    function(ctx)
                      return ctx.idx == 10 and '0' or ctx.idx >= 10 and ' ' or tostring(ctx.idx)
                    end
                  '';
                  highlight = "BlinkCmpItemIdx";
                };
                kind_icon = {
                  ellipsis = false;
                  text.__raw = ''
                    function(ctx)
                      local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                      -- Check for both nil and the default fallback icon
                      if not kind_icon or kind_icon == '󰞋' then
                        -- Use our configured kind_icons
                        return require('blink.cmp.config').appearance.kind_icons[ctx.kind] or ""
                      end
                      return kind_icon
                    end,
                    -- Optionally, you may also use the highlights from mini.icons
                    highlight = function(ctx)
                      local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                      return hl
                    end
                  '';
                };
              };
            };
          };
        };

        fuzzy = {
          implementation = "rust";
          sorts = [
            "exact"
            "score"
            "sort_text"
          ];
          prebuilt_binaries = {
            download = false;
          };
        };

        appearance = {
          kind_icons = {
            Text = "";
            Field = "";
            Variable = "";
            Class = "";
            Interface = "";
            TypeParameter = "";
          };
        };

        keymap = {
          preset = "enter";
          "<c-space>" = [
            "show"
            "show_documentation"
            "hide_documentation"
          ];
        };

        signature = {
          enabled = true;
          window.border = "single";
        };
        snippets.preset = "mini_snippets";

        sources = {
          default = lib.mkBefore [
            "buffer"
            "lsp"
            "path"
            "snippets"
            "ripgrep"
          ];

          providers = {
            buffer = {
              score_offset = 45;
              min_keyword_length = 2;
              max_items = 15;
              opts = {
                get_bufnrs.__raw = ''
                  function()
                    if vim.g.blink_buffer_all_buffers == nil then vim.g.blink_buffer_all_buffers = true end

                    if vim.g.blink_buffer_all_buffers then
                      return vim.tbl_filter(function(bufnr)
                        return vim.bo[bufnr].buftype == ""
                      end, vim.api.nvim_list_bufs())
                    else
                      return { vim.api.nvim_get_current_buf() }
                    end
                  end
                '';
              };
            };

            lsp = {
              score_offset = 80;
              fallbacks = [ ]; # Allow buffer to show independently
              transform_items.__raw = ''
                function(_, items)
                  return vim.tbl_filter(function(item)
                    return item.kind ~= require('blink.cmp.types').CompletionItemKind.Keyword
                  end, items)
                end
              '';
            };

            path = {
              score_offset = 55;
              opts = {
                get_cwd.__raw = ''
                  function(context)
                    if vim.g.blink_path_from_cwd == nil then vim.g.blink_path_from_cwd = false end

                    if vim.g.blink_path_from_cwd then
                      return vim.fn.getcwd()
                    else
                      local bufpath = vim.api.nvim_buf_get_name(context.bufnr)
                      if bufpath == "" then
                        return vim.fn.getcwd()
                      end
                      return vim.fn.fnamemodify(bufpath, ":p:h")
                    end
                  end
                '';
              };
            };

            snippets = {
              score_offset = 60;
              should_show_items.__raw = ''
                function(ctx)
                  return ctx.trigger.initial_kind ~= 'trigger_character'
                end
              '';
            };

            ripgrep = {
              name = "Ripgrep";
              module = "blink-ripgrep";
              async = true;
              timeout_ms = 500;
              max_items = 10;
              min_keyword_length = 3;
              score_offset = 5;
              opts = {
                prefix_min_len = 3;
                context_size = 5;
                max_filesize = "1M";
                project_root_marker = ".git";
                project_root_fallback = true;
                search_casing = "--ignore-case";
                fallback_to_regex_highlighting = true;
              };
            };
          };
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>uca";
        action.__raw = ''
          function()
            if vim.b.completion == false then
              vim.b.completion = true
              vim.notify("Completion On", "info")
            else
              vim.b.completion = false
              vim.notify("Completion Off", "info")
            end
          end
        '';
        options.desc = "Toggle Completions (Buffer)";
      }
      {
        mode = "n";
        key = "<leader>ucb";
        action.__raw = ''
          function()
            vim.g.blink_buffer_all_buffers = not vim.g.blink_buffer_all_buffers
            vim.notify(string.format("Buffer Completion from All Buffers %s", vim.g.blink_buffer_all_buffers and "On" or "Off"), "info")
          end
        '';
        options.desc = "Buffer Completion from All Buffers toggle";
      }
    ];
  };
}
