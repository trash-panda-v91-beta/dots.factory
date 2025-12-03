{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.fastaction";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.fastaction = {
    enable = true;

    lazyLoad.settings.event = "LspAttach";

    settings = {
      dismiss_keys = [
        "j"
        "k"
        "<Esc>"
        "<C-c>"
      ];
    };
  };
}
