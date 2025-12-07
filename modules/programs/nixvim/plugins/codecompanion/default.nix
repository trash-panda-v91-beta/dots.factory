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

    extraPlugins = [
      pkgs.vimPlugins.codecompanion-history-nvim
      pkgs.local.codecompanion-gitcommit-nvim
    ];
    plugins = {
      blink-cmp.settings.sources = {
        default = lib.mkAfter [ "codecompanion" ];
        providers.codecompanion = {
          enabled = true;
          async = true;
          module = "codecompanion.providers.completion.blink";
          name = "codecompanion";
        };
      };

      codecompanion = {
        enable = true;
        lazyLoad.settings = {
          cmd = [
            "CodeCompanion"
            "CodeCompanionChat"
            "CodeCompanionActions"
            "CodeCompanionAdd"
          ];
          ft = [ "gitcommit" ];
        };
        settings = {
          adapters.http = {
            tavily = {
              __raw = ''
                function()
                  return require("codecompanion.adapters").extend("tavily", {
                    env = {
                      api_key = 'cmd:${lib.getExe pkgs._1password-cli} read "op://Private/op4p2ok4buizqra3jssnnoet3u/credential" --no-newline',
                    },
                  })
                 end                   
              '';
            };
          };
          display = {
            enabled = true;
            diff = {
              provider = "inline";
            };
            chat = {
              window = {
                layout = "horizontal";
                height = 0.9;
                position = "bottom";
              };
            };
          };
          extensions = {
            gitcommit = {
              callback = "codecompanion._extensions.gitcommit";
              opts = {
                languages = [ "English" ];
              };
            };
            history = {
              enabled = true;
              opts = {
                picker = "default";
              };
            };
          };
          strategies = {
            chat = {
              keymaps = {
                send = {
                  modes = {
                    n = "s";
                  };
                };
              };
            };
          };
        };
      };
    };
    keymaps = [
      # Quick toggle with Ctrl+S (works in all modes)
      {
        mode = [
          "n"
          "v"
          "i"
        ];
        key = "<C-s>";
        action = "<cmd>CodeCompanionChat Toggle<CR>";
        options = {
          desc = "Quick CodeCompanion toggle";
          silent = true;
        };
      }
      # Leader keymaps for discoverability
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>ss";
        action = "<cmd>CodeCompanionChat Toggle<CR>";
        options = {
          desc = "CodeCompanion Chat";
          silent = true;
        };
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>sa";
        action = "<cmd>CodeCompanionActions<CR>";
        options = {
          desc = "CodeCompanion Actions";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>sh";
        action.__raw = ''
          function()
            require("codecompanion").history()
          end
        '';
        options = {
          desc = "CodeCompanion History";
          silent = true;
        };
      }
      # Inline prompt for quick AI queries
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>si";
        action = "<cmd>CodeCompanion<CR>";
        options = {
          desc = "CodeCompanion inline";
          silent = true;
        };
      }
    ];
  };
}
