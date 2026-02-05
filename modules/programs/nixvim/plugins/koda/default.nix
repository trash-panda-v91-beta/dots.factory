{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.koda";

  options.programs.nixvim.plugins.koda = with delib; {
    enable = boolOption true;
  };

  home.ifEnabled = {
    programs.nixvim = {
      extraPlugins = [ pkgs.local.koda-nvim ];
      extraConfigLua = ''
        require("koda").setup({ auto = false, cache = true, })
      '';
    };
  };
}
