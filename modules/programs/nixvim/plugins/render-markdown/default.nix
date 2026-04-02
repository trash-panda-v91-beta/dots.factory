{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.render-markdown";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.render-markdown =
    let
      filetypes = [
        "codecompanion"
        "markdown"
        "opencode_output"
      ];
    in
    {
      enable = true;
      lazyLoad.settings.ft = filetypes;
      settings = {
        completions = {
          lsp = {
            enabled = true;
          };
        };
        file_types = filetypes;
        render_modes = true;
      };
    };
}
