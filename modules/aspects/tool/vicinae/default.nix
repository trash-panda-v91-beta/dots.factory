{ inputs, ... }:
{
  dots.tool._.vicinae = {
    description = "Vicinae launcher";

    includes = [
      { homeManager.imports = [ inputs.vicinae.homeManagerModules.default ]; }
    ];

    homeManager =
      { config, pkgs, lib, ... }:
      let
        herdrExt = pkgs.local.herdr-ext;
        misdrExt = pkgs.local.misdr-ext;
      in
      {
        programs.vicinae = {
          enable = true;
          package = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default;
          launchd.enable = true;
          extensions = [ herdrExt misdrExt ];
          settings = {
            "$schema" = "https://vicinae.com/schemas/config.json";
            telemetry.system_info = false;
            close_on_focus_loss = true;
            pop_to_root_on_close = true;
            favicon_service = "twenty";
            global_shortcuts.toggle = "shift+SPACE";
            font = {
              rendering = "qt";
              normal.family = "JetBrains Mono";
            };
            launcher_window.material = "liquid_glass";
            providers = {
              clipboard.entrypoints.history.shortcut = "super+control+alt+shift+Y";
              "@trash-panda-v91-beta/herdr".entrypoints = {
                workspaces.shortcut = "super+control+alt+shift+H";
                open-k9s.shortcut = "alt+K";
              };
              "@trash-panda-v91-beta/misdr".entrypoints.tasks.shortcut = "super+control+alt+shift+M";
              "@khasbilegt/store.raycast.1password".preferences = {
                version = "v8";
                primaryAction = "copy-password";
                secondaryAction = "open-in-1password";
                closeWindowAfterCopying = true;
                reduceItemListMemoryUsage = false;
                zshPath = "/bin/zsh";
                cliPath = "${config.home.homeDirectory}/.nix-profile/bin/op";
              };
            };
          };
        };
      };
  };
}
