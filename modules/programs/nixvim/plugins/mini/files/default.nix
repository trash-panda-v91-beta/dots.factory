{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.mini.files";
  options = delib.singleEnableOption true;
  home.ifEnabled.programs.nixvim = {
    plugins.mini = {
      enable = true;
      modules.files = {
        mappings = {
          synchronize = "s";
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "-";
        action = ":lua  MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>";
        options = {
          desc = "Open file explorer in current folder";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "_";
        action = ":lua  MiniFiles.open()<CR>";
        options = {
          desc = "Open file explorer";
          silent = true;
        };
      }
    ];
  };
}
