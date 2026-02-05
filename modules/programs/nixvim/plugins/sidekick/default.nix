{
  delib,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.sidekick";

  options = delib.singleEnableOption true;

  myconfig.ifEnabled.unfreePackages.allow = [
    "copilot-language-server"
  ];

  home.ifEnabled.programs.nixvim = {

    plugins = {
      sidekick = {
        enable = true;
        settings = {
          mux = {
            enabled = true;
          };
        };
      };
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
            -- Apply next edit suggestion
            if require("sidekick").nes_jump_or_apply() then
              return "" -- Success, consume keystroke
            end
            return "<Tab>" -- Fallback to normal tab
          end
        '';
        options = {
          expr = true;
          desc = "Goto/Apply Next Edit Suggestion";
        };
      }
      {
        mode = "n";
        key = "<leader>sn";
        action.__raw = ''
          function()
            local was_enabled = vim.g.sidekick_nes ~= false
            require("sidekick.nes").toggle()
            local status = was_enabled and "disabled" or "enabled"
            vim.notify(string.format("Next Edit Suggestions: %s", status), vim.log.levels.INFO)
          end
        '';
        options.desc = "Toggle Next Edit Suggestions";
      }
      {
        mode = "n";
        key = "<leader>sq";
        action.__raw = "function() require('sidekick.cli').close() end";
        options.desc = "Close Sidekick UI";
      }
      {
        mode = "n";
        key = "<leader>ss";
        action.__raw = "function() require('sidekick.cli').select_session() end";
        options.desc = "Select Sidekick Session";
      }
      {
        mode = "n";
        key = "<leader>s/";
        action.__raw = "function() require('sidekick.cli').quick_chat() end";
        options.desc = "Quick Chat";
      }
      {
        mode = "n";
        key = "<leader>sd";
        action.__raw = "function() require('sidekick.cli').diff_open() end";
        options.desc = "Open Diff";
      }
      {
        mode = "n";
        key = "<leader>sz";
        action.__raw = "function() require('sidekick.cli').toggle_zoom() end";
        options.desc = "Toggle Zoom";
      }
      {
        mode = "n";
        key = "<leader>sm";
        action.__raw = "function() require('sidekick.cli').configure_provider() end";
        options.desc = "Configure Model/Provider";
      }
    ];
  };
}
