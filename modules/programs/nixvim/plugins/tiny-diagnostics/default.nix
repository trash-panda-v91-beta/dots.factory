{ delib, pkgs, lib, ... }:
delib.module {
  name = "programs.nixvim.plugins.tiny-diagnostics";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    extraPlugins = [ pkgs.local.tiny-diagnostics-nvim ];

    extraConfigLua = ''
      require("tiny-diagnostics").setup({
        options = {
          show_source = true,
          multiline = true,
          overflow = {
            mode = "wrap",
          },
        },
      })
    '';

    # Override diagnostic settings to disable default virtual text
    # since tiny-diagnostics provides a better alternative
    # Use mkForce to override the existing configuration
    diagnostic.settings.virtual_text = lib.mkForce false;
  };
}
