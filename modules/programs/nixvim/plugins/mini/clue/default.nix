{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.mini.clue";
  options = delib.singleEnableOption false;
  home.ifEnabled.programs.nixvim.plugins.mini = {
    enable = true;
    modules.clue = {
      triggers = [
        {
          mode = "n";
          keys = "<Leader>";
        }
        {
          mode = "x";
          keys = "<Leader>";
        }
        {
          mode = "n";
          keys = "[";
        }
        {
          mode = "n";
          keys = "]";
        }
        {
          mode = "i";
          keys = "<C-x>";
        }
        {
          mode = "n";
          keys = "g";
        }
        {
          mode = "x";
          keys = "g";
        }
        {
          mode = "n";
          keys = "\"";
        }
        {
          mode = "n";
          keys = "`";
        }
        {
          mode = "x";
          keys = "\"";
        }
        {
          mode = "x";
          keys = "`";
        }
        {
          mode = "n";
          keys = ",";
        }
        {
          mode = "x";
          keys = ",";
        }
        {
          mode = "i";
          keys = "<C-r>";
        }
        {
          mode = "c";
          keys = "<C-r>";
        }
        {
          mode = "n";
          keys = "<C-w>";
        }
        {
          mode = "n";
          keys = "z";
        }
        {
          mode = "x";
          keys = "z";
        }
      ];
    };
  };
}
