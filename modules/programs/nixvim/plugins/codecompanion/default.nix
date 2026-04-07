{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.codecompanion";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {

    plugins = {
      blink-cmp.settings.sources = {
        per_filetype.codecompanion = lib.mkAfter [ "codecompanion" ];
        per_filetype.codecompanion_terminal = lib.mkAfter [ "codecompanion" ];
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
              desc = "Toggle CodeCompanion CLI";
            }
            {
              __unkeyed-1 = "<C-a>";
              __unkeyed-2.__raw = "function() require('codecompanion').toggle_cli() end";
              desc = "Toggle CodeCompanion CLI";
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
              cmd = pkgs.lib.getExe pkgs.claude-code;
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
