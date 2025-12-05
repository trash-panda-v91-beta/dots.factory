{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.input";
  options = delib.singleEnableOption true;
  home.ifEnabled.programs.nixvim = {
    plugins.snacks.settings = {
      styles = {
        above_cursor = {
          relative = "cursor";
          row = -3;
          col = 0;
          border = "single";
          title_pos = "left";
          height = 1;
          noautocmd = true;
          wo = {
            cursorline = false;
          };
          bo = {
            filetype = "snacks_input";
            buftype = "prompt";
          };
          # buffer local variables
          b = {
            completion = true; # enable/disable blink completions in input
          };
          keys = {
            n_esc = {
              __unkeyed-1 = "<esc>";
              __unkeyed-2 = [ "cancel" ];
              mode = "n";
              expr = true;
            };
            i_esc = {
              __unkeyed-1 = "<esc>";
              __unkeyed-2 = [ "stopinsert" ];
              mode = "i";
              expr = true;
            };
            i_cr = {
              __unkeyed-1 = "<cr>";
              __unkeyed-2 = [ "confirm" ];
              mode = "i";
              expr = true;
            };
            i_ctrl_w = {
              __unkeyed-1 = "<c-w>";
              __unkeyed-2 = "<c-s-w>";
              mode = "i";
              expr = true;
            };
            i_up = {
              __unkeyed-1 = "<up>";
              __unkeyed-2 = [ "hist_up" ];
              mode = [
                "i"
                "n"
              ];
            };
            i_down = {
              __unkeyed-1 = "<down>";
              __unkeyed-2 = [ "hist_down" ];
              mode = [
                "i"
                "n"
              ];
            };
            q = "cancel";
          };
        };
      };
      input = {
        enabled = true;
        win = {
          style = "above_cursor";
        };
      };
    };
  };
}
