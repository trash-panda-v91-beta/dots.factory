{
  delib,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.sidekick";

  options = delib.singleEnableOption false;

  myconfig.ifEnabled.unfreePackages.allow = [
    "copilot-language-server"
  ];

  home.ifEnabled.programs.nixvim = {

    plugins = {
      sidekick = {
        enable = true;
        settings = {
          mux = {
            enableb = true;
          };
        };
      };

      which-key.settings.spec = [
        {
          __unkeyed-1 = "<leader>s";
          group = "Sidekick";
          icon = "🤖";
          mode = [
            "n"
            "v"
          ];
        }
      ];
    };

    keymaps = [
      {
        mode = [
          "n"
          "i"
        ];
        key = "<Tab>";
        action.__raw = ''
          function()
            if not require("sidekick").nes_jump_or_apply() then
              return "<Tab>"
            end
          end
        '';
        options = {
          expr = true;
          desc = "Goto/Apply Next Edit Suggestion";
        };
      }
      {
        mode = "n";
        key = "<leader>st";
        action.__raw = "function() require('sidekick.cli').toggle({ focus = true }) end";
        options.desc = "Sidekick Toggle";
      }
      {
        mode = [
          "n"
          "v"
          "v"
        ];
        key = "<leader>sp";
        action.__raw = "function() require('sidekick.cli').select_prompt() end";
        options.desc = "Ask Prompt";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>aso";
        action.__raw = "function() require('sidekick.cli').toggle({ name = 'opencode', focus = true }) end";
        options.desc = "Opencode Toggle";
      }
    ];
  };
}
