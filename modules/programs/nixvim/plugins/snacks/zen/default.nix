{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.zen";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    plugins.snacks.settings.zen.enabled = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>bz";
        action = "<cmd>lua Snacks.zen.zoom()<cr>";
        options.desc = "Zoom buffer (toggle)";
      }
    ];
  };
}
