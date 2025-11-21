{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.rename";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.nixvim = {
      plugins.snacks.settings.rename.enabled = true;

      keymaps = [
        {
          mode = "n";
          key = "<leader>cr";
          action = "<cmd>lua Snacks.rename.rename_file()<CR>";
          options.desc = "Rename File";
        }
      ];
    };
  };
}
