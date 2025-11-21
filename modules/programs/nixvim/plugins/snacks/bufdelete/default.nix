{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.bufdelete";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.nixvim = {
      plugins.snacks.settings.bufdelete.enabled = true;

      keymaps = [
        {
          mode = "n";
          key = "<C-w>";
          action = "<cmd>lua Snacks.bufdelete.delete()<cr>";
          options.desc = "Close buffer";
        }
        {
          mode = "n";
          key = "<leader>bc";
          action = "<cmd>lua Snacks.bufdelete.other()<cr>";
          options.desc = "Close all buffers but current";
        }
        {
          mode = "n";
          key = "<leader>bC";
          action = "<cmd>lua Snacks.bufdelete.all()<cr>";
          options.desc = "Close all buffers";
        }
      ];
    };
  };
}
