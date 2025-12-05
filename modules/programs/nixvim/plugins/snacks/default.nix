{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks";
  options = delib.singleEnableOption true;
  home.ifEnabled.programs.nixvim = {
    plugins.snacks = {
      enable = true;

      settings = {
        # Scratch buffer configuration (like reference)
        scratch = {
          backdrop = false;
        };

        # Words plugin disabled (like reference)
        words = {
          enabled = false;
        };

        # Bigfile notify off (like reference)
        bigfile = {
          notify = false;
        };

        # Notifier configuration (like reference)
        notifier = {
          top_down = false;
          width = {
            min = 80;
            max = 80;
          };
          height = {
            min = 1;
            max = 8;
          };
        };
      };
    };

    # Scratch buffer keymaps (like reference)
    keymaps = [
      {
        mode = "n";
        key = "<leader>..";
        action.__raw = "function() require('snacks').scratch() end";
        options.desc = "Scratch Toggle Buffer";
      }
      {
        mode = "n";
        key = "<leader>f.";
        action.__raw = "function() require('snacks').scratch.select() end";
        options.desc = "Scratch Select Buffer";
      }
    ];
  };
}
