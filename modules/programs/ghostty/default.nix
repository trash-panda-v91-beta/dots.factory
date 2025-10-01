{
  delib,
  ...
}:
delib.module {
  name = "programs.ghostty";

  options = delib.singleEnableOption true;
  darwin.ifEnabled =
    { myconfig, ... }:
    {
      # TODO: use nixpkgs once available
      homebrew.casks = [ "ghostty" ];
      home-manager.users.${myconfig.user.name}.programs.ghostty.package = null;
    };

  home.ifEnabled = {
    programs.ghostty = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      settings = {
        adjust-cell-height = "30%";
        custom-shader = [
          "${shaders/bloom025.glsl}"
          "${shaders/cursor_blaze_no_trail.glsl}"
          "${shaders/cursor_smear.glsl}"
        ];
        background-opacity = 0.95;
        background-blur-radius = 30;
        copy-on-select = true;
        cursor-style = "block";
        font-family = "JetBrains Mono";
        font-size = 16;
        font-thicken = true;
        mouse-hide-while-typing = true;
        macos-non-native-fullscreen = false;
        macos-option-as-alt = true;
        macos-titlebar-proxy-icon = "hidden";
        title = " ";
        shell-integration-features = "no-title";
        macos-titlebar-style = "hidden";
        window-padding-y = "0,0";
        window-padding-x = 20;
        window-padding-color = "extend";
        window-padding-balance = true;
        window-save-state = "always";
        quit-after-last-window-closed = true;

        keybind = [
          "super+t=ignore"
          "super+d=ignore"
        ];
      };
    };
  };
}
