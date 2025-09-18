{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.blink-cmp";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.blink-cmp = {
    enable = true;

    lazyLoad.settings.event = [
      "CmdlineEnter"
      "InsertEnter"
    ];
    settings = {
      completion = {
        list = {
          selection = {
            auto_insert = true;
            preselect = false;
          };
        };
      };
      fuzzy = {
        implementation = "rust";
        prebuilt_binaries = {
          download = false;
        };
      };
      signature = {
        enabled = true;
      };
      snippets.preset = "mini_snippets";
      sources = {
        default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
      };
    };

  };
}
