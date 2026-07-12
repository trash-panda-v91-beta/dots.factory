{ inputs, ... }:
{
  dots.tool._.vicinae = {
    description = "Vicinae launcher";

    # TODO: switch back to programs.vicinae.settings once the HM module supports macOS
    # (currently Linux-only; xdg.configFile assertion prevents it writing on macOS).
    includes = [
      { homeManager.imports = [ inputs.vicinae.homeManagerModules.default ]; }
      {
        homeManager.imports = [
          ({ lib, ... }: {
            options.vicinae.extraProviders = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = {};
              description = "Extra provider entries merged into vicinae settings.json.";
            };
          })
        ];
      }
    ];

    homeManager =
      { config, pkgs, lib, ... }:
      let
        herdrZjumpExt = pkgs.buildNpmPackage {
          name = "zerdr";
          src = ./zerdr;
          inherit (pkgs.importNpmLock) npmConfigHook;
          npmDeps = pkgs.importNpmLock { npmRoot = ./zerdr; };
          installPhase = ''
            runHook preInstall
            mkdir -p $out
            npm run build -- --out $out
            runHook postInstall
          '';
        };
        vicinaeSettings = (pkgs.formats.json { }).generate "vicinae-settings" {
          "$schema" = "https://vicinae.com/schemas/config.json";
          telemetry.system_info = false;
          close_on_focus_loss = true;
          pop_to_root_on_close = true;
          favicon_service = "twenty";
          global_shortcuts.toggle = "control+SPACE";
          font = {
            rendering = "qt";
            normal.family = "JetBrains Mono";
          };
          launcher_window.material = "liquid_glass";
          # TODO: move to rice/cyberdream-dark.nix once programs.vicinae.settings works on darwin
          theme.dark.name = "Cyberdream";
          providers = {
            clipboard.entrypoints.history.shortcut = "super+control+alt+shift+Y";
            "@${config.home.username}/zerdr".entrypoints.jump.shortcut = "super+control+alt+shift+Z";
            "@khasbilegt/store.raycast.1password".preferences = {
              version = "v8";
              primaryAction = "copy-password";
              secondaryAction = "open-in-1password";
              closeWindowAfterCopying = true;
              reduceItemListMemoryUsage = false;
              zshPath = "/bin/zsh";
              cliPath = "${config.home.homeDirectory}/.nix-profile/bin/op";
            };
          } // config.vicinae.extraProviders;
        };
      in
      {
        programs.vicinae = {
          enable = true;
          package = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };

        xdg.dataFile."vicinae/extensions/zerdr".source = herdrZjumpExt;

        xdg.configFile."vicinae/settings.json".source = vicinaeSettings;

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
