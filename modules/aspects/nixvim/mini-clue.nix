{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._."mini-clue" ];
  dots.nixvim._."mini-clue".homeManager = { ... }: {
  programs.nixvim.plugins.mini = {
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
  };
}
