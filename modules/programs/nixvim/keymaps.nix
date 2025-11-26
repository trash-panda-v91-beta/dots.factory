{
  delib,
  ...
}:
delib.module {
  name = "programs.nixvim.keymaps";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>/";
      action = "<cmd>nohl<CR>";
      options = {
        desc = "Clear search";
      };
    }
  ];
}
