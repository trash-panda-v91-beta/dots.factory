{ delib, ... }:
delib.overlayModule {
  name = "sidekick";
  overlay = final: prev: {
    vimPlugins = prev.vimPlugins // {
      sidekick-nvim = prev.vimPlugins.sidekick-nvim.overrideAttrs {
        version = "2025-10-01";
        src = prev.fetchFromGitHub {
          owner = "folke";
          repo = "sidekick.nvim";
          rev = "8c940476cae4e2ba779ed6c73080d097694e406c";
          sha256 = "0qwi3kcsww7nax5nyi3yrxc20dc6n9qijqf5mrwy771aqv7ch3as";
        };
      };
    };
  };
}
