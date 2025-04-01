{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.modules.desktop.hyprland;
in
{
  options.modules.desktop.hyprland = {
    enable = lib.mkEnableOption "hyprland";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    wayland.windowManager.hyprland.settings = {
      input = {
        natural_scroll = true;
        kb_options = "ctrl:nocaps";
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
        };
      };

      device = [
        {
          name = "at-translated-set-2-keyboard";
          kb_options = "ctrl:nocaps, altwin:swap_alt_win";
        }
      ];

      windowrulev2 = [
        "float,class:(1Password)"
        "float,class:(Rofi)"
      ];

      cursor = {
        no_hardware_cursors = true;
      };

      env = [
        "WLR_DRM_DEVICES,/dev/dri/card2:/dev/dri/card1"
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];

      monitor = [
        "DP-1, preferred, auto, 1"
        "eDP-1, preferred, auto, 1"
      ];

      "$mod" = "SUPER";
      bind = [
        "$mod, SPACE, exec, rofi -show drun"
        "$mod, J, exec, wezterm"
        "$mod, F, exec, firefox"
        "$mod, M, exit"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3:"
        "$mod, 4, workspace, 4"
        "$mod, mouse:272, movewindow"
        "$mod, S, togglespecialworkspace, magic"
      ];
      binde = [
        ", XF86MonBrightnessUp, exec, brightnessctl -c backlight s '10%+'"
        ", XF86MonBrightnessDown, exec, brightnessctl -c backlight s '10%-'"
        ", xf86audioraisevolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", xf86audiolowervolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];
    };
    home.packages = with pkgs; [
      brightnessctl
      rofi-wayland
    ];
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
