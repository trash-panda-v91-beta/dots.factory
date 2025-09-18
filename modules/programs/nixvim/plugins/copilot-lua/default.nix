{ delib, host, ... }:
delib.module {
  name = "programs.nixvim.plugins.copilot-lua";

  options = delib.singleEnableOption host.githubCopilotFeatured;

  home.ifEnabled.programs.nixvim.plugins = {
    blink-copilot.enable = true;
    blink-cmp.settings.sources = {
      default = [ "copilot" ];
      providers.copilot = {
        enabled = true;
        async = true;
        module = "blink-copilot";
        name = "copilot";
      };
    };
    copilot-lua = {
      lazyLoad.settings.event = [
        "InsertEnter"
      ];
      enable = true;
      settings = {
        panel.enable = false;
        suggestions.enable = false;
      };
    };
  };
}
