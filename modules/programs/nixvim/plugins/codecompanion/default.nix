{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.codecompanion";

  options = delib.singleEnableOption true;

  home.ifEnabled =
    { myconfig, ... }:
    {
      programs.nixvim.plugins = {
        which-key.settings.spec = [
          {
            __unkeyed-1 = "<leader>a";
            group = "Agent";
            icon = "";
            mode = [
              "n"
              "v"
            ];
          }
          {
            __unkeyed-1 = "<leader>af";
            group = "Fix";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>ag";
            group = "Git";
            icon = "";
          }
        ];

        blink-cmp.settings.sources = {
          per_filetype.codecompanion = lib.mkAfter [ "codecompanion" ];
          per_filetype.codecompanion_terminal = lib.mkAfter [ "codecompanion" ];
          per_filetype.codecompanion_input = lib.mkAfter [ "codecompanion" ];
          providers.codecompanion = {
            async = true;
            module = "codecompanion.providers.completion.blink";
            name = "codecompanion";
          };
        };

        codecompanion = {
          enable = true;
          package = pkgs.vimPlugins.codecompanion-nvim;
          lazyLoad.settings = {
            cmd = [
              "CodeCompanion"
              "CodeCompanionChat"
              "CodeCompanionActions"
              "CodeCompanionAdd"
              "CodeCompanionCLI"
            ];
            ft = [ ];
            keys = [
              {
                __unkeyed-1 = "<leader>aa";
                __unkeyed-2.__raw = "function() require('codecompanion').toggle_cli() end";
                mode = [
                  "n"
                  "v"
                ];
                desc = "[A]gent toggle";
              }
              {
                __unkeyed-1 = "<C-a>";
                __unkeyed-2.__raw = "function() require('codecompanion').toggle_cli() end";
                desc = "Toggle CodeCompanion CLI";
              }
              {
                __unkeyed-1 = "<leader>ap";
                __unkeyed-2.__raw = "function() require('codecompanion').cli({ prompt = true }) end";
                mode = [
                  "n"
                  "v"
                ];
                desc = "[A]gent [P]rompt";
              }
              {
                __unkeyed-1 = "<leader>at";
                __unkeyed-2.__raw = "function() require('codecompanion').cli('#{this}', { focus = false }) end";
                mode = [
                  "n"
                  "v"
                ];
                desc = "[A]gent add con[T]ext";
              }
              {
                __unkeyed-1 = "<leader>afd";
                __unkeyed-2.__raw = "function() require('codecompanion').cli('#{diagnostics} Can you fix these?', { focus = false, submit = true }) end";
                desc = "[A]gent [F]ix [D]iagnostics";
              }
              {
                __unkeyed-1 = "<leader>afe";
                __unkeyed-2.__raw = "function() require('codecompanion').cli('#{quickfix} Can you fix these errors?', { focus = false, submit = true }) end";
                desc = "[A]gent [F]ix [E]rrors (quickfix)";
              }
              {
                __unkeyed-1 = "<leader>aft";
                __unkeyed-2.__raw = "function() require('codecompanion').cli('#{terminal} Sharing the output from the terminal. Can you fix it?', { focus = false, submit = true }) end";
                desc = "[A]gent [F]ix [T]ests";
              }
              {
                __unkeyed-1 = "<leader>agc";
                __unkeyed-2.__raw = ''
                  function()
                    local diff = vim.fn.system('git diff --cached --no-ext-diff')
                    if diff == "" then
                      vim.notify("No staged changes", vim.log.levels.WARN)
                      return
                    end
                    require('codecompanion').cli('Staged diff:\n```diff\n' .. diff .. '\n```\nWrite a conventional commit message for these changes and commit them.', { focus = false, submit = true })
                  end
                '';
                desc = "[A]gent [G]it [C]ommit staged";
              }
            ];
          };

          settings = {
            display.chat = {
              window.layout = "buffer";
              floating_window = {
                width = 0.9;
                row = "center";
                col = "center";
                relative = "editor";
                opts = {
                  wrap = false;
                  number = false;
                  relativenumber = false;
                };
              };
            };

            interactions.cli = {
              agent = "claude_code";
              agents.claude_code = {
                cmd = "/etc/profiles/per-user/${myconfig.user.name}/bin/claude";
                args = [ ];
                description = "Claude Code CLI";
                provider = "terminal";
              };
              keymaps = {
                next_chat = {
                  modes.n = "}";
                  callback = "keymaps.next_chat";
                  description = "[Nav] Next interaction";
                };
                previous_chat = {
                  modes.n = "{";
                  callback = "keymaps.previous_chat";
                  description = "[Nav] Previous interaction";
                };
              };
            };
          };
        };
      };
    };
}
