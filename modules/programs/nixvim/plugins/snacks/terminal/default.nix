{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.terminal";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    plugins.snacks.settings.terminal = {
      enabled = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>lua Snacks.terminal.toggle()<CR>";
        options = {
          desc = "Toggle Terminal";
        };
      }
      {
        mode = "t";
        key = "<leader>e";
        action = "<cmd>lua Snacks.terminal.toggle()<CR>";
        options = {
          desc = "Toggle Terminal";
        };
      }
      {
        mode = "t";
        key = "<C-\\>";
        action = "<cmd>lua Snacks.terminal.toggle()<CR>";
        options = {
          desc = "Toggle Terminal";
        };
      }
    ];
  };
}
