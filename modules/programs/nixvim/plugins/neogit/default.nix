{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.neogit";
  options = delib.singleEnableOption true;
  home.ifEnabled.programs.nixvim = {
    plugins.neogit = {
      enable = true;
    };
    keymaps = [
      {
        mode = [
          "n"
        ];
        key = "<leader>gg";
        action = "<cmd>Neogit<cr>";
        options = {
          desc = "Open Neogit";
        };
      }
    ];
  };
}
