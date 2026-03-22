{
  delib,
  lib,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.codecompanion";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {

    plugins = {
      blink-cmp.settings.sources = {
        default = lib.mkAfter [ "codecompanion" ];
        providers.codecompanion = {
          enabled = true;
          async = true;
          module = "codecompanion.providers.completion.blink";
          name = "codecompanion";
        };
      };

      codecompanion = {
        enable = true;
        lazyLoad.settings = {
          cmd = [
            "CodeCompanion"
            "CodeCompanionChat"
            "CodeCompanionActions"
            "CodeCompanionAdd"
            "CodeCompanionCLI"
          ];
          ft = [ ];
        };
      };
    };
  };
}
