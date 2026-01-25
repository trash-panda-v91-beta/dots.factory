{
  delib,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.codediff";

  options.programs.nixvim.plugins.codediff = with delib; {
    enable = boolOption true;
  };

  home.ifEnabled =
    { ... }:
    {
      programs.nixvim = {
        plugins.codediff = {
          enable = true;
          settings = {
            # Default keymaps for the explorer view
            keymaps = {
              explorer = {
                select = "<CR>";
                hover = "K";
                refresh = "R";
              };
              view = {
                next_hunk = "]c";
                prev_hunk = "[c";
                next_file = "]f";
                prev_file = "[f";
              };
            };
          };
        };

        keymaps = [
          {
            mode = [ "n" ];
            key = "<leader>gd";
            action = "<cmd>CodeDiff<cr>";
            options = {
              desc = "Open CodeDiff";
            };
          }
        ];
      };
    };
}
