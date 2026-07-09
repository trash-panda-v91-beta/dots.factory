{ inputs, ... }:
{
  dots.tool._.vicinae = {
    description = "Vicinae launcher";

    includes = [ { homeManager.imports = [ inputs.vicinae.homeManagerModules.default ]; } ];

    homeManager =
      { config, pkgs, ... }:
      {
        programs.vicinae = {
          enable = true;
          package = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default;
          settings = {
            telemetry.system_info = false;
            close_on_focus_loss = true;
            pop_to_root_on_close = true;
            favicon_service = "twenty";
            global_shortcuts.toggle = "control+SPACE";
            font.normal.family = "JetBrains Mono";
            launcher_window.material = "liquid_glass";
            providers.clipboard.entrypoints.history.shortcut = "super+control+shift+alt+Y";
            providers."@khasbilegt/store.raycast.1password".preferences = {
              version = "v8";
              primaryAction = "copy-password";
              secondaryAction = "open-in-1password";
              closeWindowAfterCopying = true;
              reduceItemListMemoryUsage = false;
              zshPath = "/bin/zsh";
              cliPath = "/Users/trash-panda-v91-beta/.nix-profile/bin/op";
            };
          };
        };

        launchd.agents.vicinae = {
          enable = true;
          config = {
            ProgramArguments = [
              "${inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/vicinae"
              "server"
            ];
            RunAtLoad = true;
            KeepAlive = true;
            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/vicinae/vicinae.log";
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/vicinae/vicinae.log";
          };
        };
      };
  };
}
