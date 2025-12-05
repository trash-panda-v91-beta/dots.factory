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
      {
        mode = [
          "n"
          "v"
        ];
        key = "<A-c>";
        action = "<cmd>CodeCompanionChat Toggle<CR>";
        options = {
          desc = "Trigger CodeCompanion chat";
          silent = true;
        };
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<A-i>";
        action = "<cmd>CodeCompanion<CR>";
        options = {
          desc = "Trigger CodeCompanion inline";
          silent = true;
        };
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<localleader>aa";
        action = "<cmd>CodeCompanionActions<CR>";
        options = {
          desc = "Trigger CodeCompanion actions";
          silent = true;
        };
      }
    ];
  };
}
