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
            options.vicinae.extraSettings = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = {};
              description = "Extra top-level settings merged into vicinae settings.json.";
            };
          })
        ];
      }
    ];

    homeManager =
      { config, pkgs, lib, ... }:
      let
        misdrExt = pkgs.buildNpmPackage {
          name = "misdr";
          src = ./misdr;
          inherit (pkgs.importNpmLock) npmConfigHook;
          npmDeps = pkgs.importNpmLock { npmRoot = ./misdr; };
          installPhase = ''
            runHook preInstall
            mkdir -p $out
            npm run build -- --out $out
            runHook postInstall
          '';
        };
        awsExt = pkgs.buildNpmPackage {
          name = "aws";
          src = pkgs.fetchgit {
            url = "https://github.com/raycast/extensions";
            rev = "d302c9d6429735e9936442de8bceec85877cbd21";
            sha256 = "sha256-BtMFj1lr72NCAyDpOourR6V7dfVB4OKEdNGNyz6pDSM=";
            sparseCheckout = [ "/extensions/amazon-aws" ];
          } + "/extensions/amazon-aws";
          inherit (pkgs.importNpmLock) npmConfigHook;
          npmDeps = pkgs.importNpmLock {
            npmRoot = pkgs.fetchgit {
              url = "https://github.com/raycast/extensions";
              rev = "d302c9d6429735e9936442de8bceec85877cbd21";
              sha256 = "sha256-BtMFj1lr72NCAyDpOourR6V7dfVB4OKEdNGNyz6pDSM=";
              sparseCheckout = [ "/extensions/amazon-aws" ];
            } + "/extensions/amazon-aws";
          };
          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r "$HOME/.config/raycast/extensions"/*/. $out/
            runHook postInstall
          '';
        };
        herdrExt = pkgs.buildNpmPackage {
          name = "herdr";
          src = ./herdr;
          inherit (pkgs.importNpmLock) npmConfigHook;
          npmDeps = pkgs.importNpmLock { npmRoot = ./herdr; };
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
            "@Falcon/store.raycast.aws".preferences.useAWSVault = false;
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
        } // config.vicinae.extraSettings;
      in
      {
        programs.vicinae = {
          enable = true;
          package = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };

        xdg.dataFile."vicinae/extensions/store.raycast.aws".source = awsExt;
        xdg.dataFile."vicinae/extensions/herdr".source = herdrExt;
        xdg.dataFile."vicinae/extensions/misdr".source = misdrExt;

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
