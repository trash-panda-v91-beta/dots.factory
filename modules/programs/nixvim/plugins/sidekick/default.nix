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
            -- Try to jump or apply next edit suggestion
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
        key = "<leader>so";
        action.__raw = "function() require('sidekick.cli').toggle({ name = 'opencode', focus = true }) end";
        options.desc = "Toggle OpenCode";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>st";
        action.__raw = "function() require('sidekick.cli').send({ msg = '{this}' }) end";
        options.desc = "Send This";
      }
      {
        mode = "n";
        key = "<leader>sf";
        action.__raw = "function() require('sidekick.cli').send({ msg = '{file}' }) end";
        options.desc = "Send File";
      }
      {
        mode = "v";
        key = "<leader>sv";
        action.__raw = "function() require('sidekick.cli').send({ msg = '{selection}' }) end";
        options.desc = "Send Selection";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>sp";
        action.__raw = "function() require('sidekick.cli').prompt() end";
        options.desc = "Select Prompt";
      }
      {
        mode = "n";
        key = "<leader>sc";
        action.__raw = ''
          function()
            -- Check current state before toggling (nil/true = enabled, false = disabled)
            local was_enabled = vim.g.sidekick_nes ~= false
            
            -- Toggle the state
            require("sidekick.nes").toggle()
            
            -- Show the new state (opposite of what it was)
            local status = was_enabled and "disabled" or "enabled"
            vim.notify(
              string.format("Next Edit Suggestions: %s", status),
              vim.log.levels.INFO
            )
          end
        '';
        options.desc = "Toggle Next Edit Suggestions";
      }
    ];
  };
}
