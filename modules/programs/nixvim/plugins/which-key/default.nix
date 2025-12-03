{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.which-key";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.which-key = {
    enable = true;

    settings = {
      spec = [
        {
          __unkeyed-1 = "<leader>s";
          group = "Sidekick";
          icon = "";
          mode = [
            "n"
            "v"
          ];
        }
        {
          __unkeyed-1 = "<leader>b";
          group = "Buffers";
          icon = "󰓩";
        }
        {
          __unkeyed-1 = "<leader>c";
          group = "Code";
          icon = "";
          mode = [
            "n"
            "v"
          ];
        }
        {
          __unkeyed-1 = "<leader>d";
          group = "Debug";
          icon = "";
        }
        {
          __unkeyed-1 = "<leader>f";
          group = "Find";
          icon = "";
        }
        {
          __unkeyed-1 = "<leader>g";
          group = "Git";
          icon = "";
          mode = [
            "n"
            "v"
          ];
        }
        {
          __unkeyed-1 = "<leader>gd";
          group = "Diff";
          icon = "";
        }
        {
          __unkeyed-1 = "<leader>gh";
          group = "Hunk";
          icon = "";
        }
        {
          __unkeyed-1 = "<leader>n";
          group = "Notifications";
          icon = "";
        }
        {
          __unkeyed-1 = "<leader>q";
          group = "Quit/Session";
          icon = "󰗼";
        }
        {
          __unkeyed-1 = "<leader>s";
          group = "Search";
          icon = "";
        }
        {
          __unkeyed-1 = "<leader>t";
          group = "Terminal/Test";
          icon = "";
        }
        {
          __unkeyed-1 = "<leader>u";
          group = "UI";
          icon = "󰙵";
        }
        {
          __unkeyed-1 = "<leader>w";
          group = "Windows";
          icon = "";
        }
        {
          __unkeyed-1 = "<leader>x";
          group = "Diagnostics/Quickfix";
          icon = "󱖫";
        }
        {
          __unkeyed-1 = "[";
          group = "Previous";
        }
        {
          __unkeyed-1 = "]";
          group = "Next";
        }
        {
          __unkeyed-1 = "g";
          group = "Goto";
        }
        {
          __unkeyed-1 = "gs";
          group = "Surround";
        }
      ];

      replace = {
        desc = [
          [
            "<space>"
            "SPACE"
          ]
          [
            "<leader>"
            "SPACE"
          ]
          [
            "<[cC][rR]>"
            "RETURN"
          ]
          [
            "<[tT][aA][bB]>"
            "TAB"
          ]
          [
            "<[bB][sS]>"
            "BACKSPACE"
          ]
        ];
      };

      win = {
        border = "single";
      };
    };
  };
}
