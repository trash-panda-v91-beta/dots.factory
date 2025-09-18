{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.tiny-glimmer";

  options = delib.singleEnableOption false;

  home.ifEnabled.programs.nixvim.plugins.tiny-glimmer-nvim = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
    settings = {
      transparency_color = "#151718";
      overwrite = {
        yank.enabled = true;
        paste.enable = true;
        undo.enabled = true;
        redo.enabled = true;
      };
    };
    # extraPlugins = [ pkgs.local.tiny-glimmer-nvim ];
    # extraConfigLua = ''require("tiny-glimmer").setup()'';
  };
}
