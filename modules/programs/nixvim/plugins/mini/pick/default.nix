{ delib, pkgs, ... }:
delib.module {
  name = "programs.nixvim.plugins.mini.pick";
  options = delib.singleEnableOption false;
  home.ifEnabled.programs.nixvim = {
    extraFiles."lua/smartpick.lua".source = ./smartpick.lua;
    extraPackages = with pkgs; [ ripgrep ];
    extraConfigLua = ''SmartPick = require("smartpick").setup()'';
    plugins.mini = {
      enable = true;
      modules.pick = { };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader><space>";
        action = ":lua MiniPick.builtin.files({ tool = 'rg' })<CR>";
        options = {
          desc = "Find files";
        };
      }
      {
        mode = "n";
        key = "<leader>fs";
        action.__raw = ''
          function() 
            require("smartpick").setup()  
          end 
        '';
      }
      {
        mode = "n";
        key = "<leader>fw";
        action = ":lua MiniPick.builtin.grep_live({ tool = 'rg' })<CR>";
        options = {
          desc = "Find by words";
        };
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = ":lua MiniPick.builtin.buffers()<CR>";
        options = {
          desc = "Find buffers";
        };
      }
    ];
  };
}
