{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.sidekick";

  options = delib.singleEnableOption true;

  myconfig.ifEnabled.unfreePackages.allow = [ "copilot-language-server" ];

  home.ifEnabled.programs.nixvim = {

    plugins.which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>as";
        group = "Sidekick";
        icon = "🤖";
      }
    ];

    extraPlugins = [
      pkgs.master.vimPlugins.sidekick-nvim
    ];

    extraConfigLua =
      let
        settings = {
          mux = {
            enabled = true;
            backend = "tmux";
          };
        };
      in
      ''
        require('sidekick').setup(${lib.generators.toLua { } settings})
      '';

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
        key = "<leader>ast";
        action.__raw = "function() require('sidekick.cli').toggle({ focus = true }) end";
        options.desc = "Sidekick Toggle";
      }
      {
        mode = [
          "n"
          "v"
          "v"
        ];
        key = "<leader>asp";
        action.__raw = "function() require('sidekick.cli').select_prompt() end";
        options.desc = "Ask Prompt";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>asc";
        action.__raw = "function() require('sidekick.cli').toggle({ name = 'claude', focus = true }) end";
        options.desc = "Claude Toggle";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>asg";
        action.__raw = "function() require('sidekick.cli').toggle({ name = 'gemini', focus = true }) end";
        options.desc = "Gemini Toggle";
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
