{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.mini.snippets";
  options = delib.singleEnableOption true;
  home.ifEnabled.programs.nixvim = {
    extraFiles = {
      "snippets/markdown.json".source = ./snippets/markdown.json;
      "snippets/nix.json".source = ./snippets/nix.json;
    };
    plugins.mini = {
      enable = true;
      modules.snippets = {
        snippets = {
          __unkeyed-2.__raw = ''
            require("mini.snippets").gen_loader.from_lang()
          '';
        };
      };
    };
  };
}
