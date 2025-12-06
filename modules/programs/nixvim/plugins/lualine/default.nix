{
  delib,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.lualine";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.lualine = {
    enable = true;
    lazyLoad.settings.event = [
      "VimEnter"
      "BufReadPost"
      "BufNewFile"
    ];
    settings = {
      options = {
        disabled_filetypes = {
          __unkeyed-1 = "neo-tree";
          __unkeyed-2 = "trouble";
          __unkeyed-3 = "dashboard";
          __unkeyed-4 = "alpha";
          __unkeyed-5 = "ministarter";
          __unkeyed-6 = "oil";
          __unkeyed-7 = "NeogitStatus";
        };
      };
    };
  };
}
