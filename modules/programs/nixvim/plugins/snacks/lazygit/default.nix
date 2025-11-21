{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.lazygit";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.nixvim = {
      plugins.snacks.settings.lazygit.enabled = true;

      keymaps = [
        {
          mode = "n";
          key = "<leader>gl";
          action = "<cmd>lua Snacks.lazygit()<CR>";
          options.desc = "Open lazygit";
        }
      ];
    };
  };
}
