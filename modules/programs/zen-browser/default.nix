{
  delib,
  inputs,
  pkgs,
  ...
}:
delib.module {
  name = "programs.zen-browser";

  options = delib.singleEnableOption true;

  home.always.imports = [
    inputs.zen-browser.homeModules.default
  ];

  darwin.ifEnabled.homebrew.casks = [ "zen" ];

  home.ifEnabled = {
    programs.zen-browser = {
      enable = true;

      # On darwin we skip Nix-managed package
      # (package = null) and install via homebrew cask instead, so macOS code-signing
      # requirements are satisfied (see: github.com/0xc000022070/zen-browser-flake/issues/82).
      package = pkgs.lib.mkIf pkgs.stdenv.isDarwin null;

      policies =
        let
          mkLockedAttrs = builtins.mapAttrs (
            _: value: {
              Value = value;
              Status = "locked";
            }
          );

          mkExtensionSettings = builtins.mapAttrs (
            _: pluginId: {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
              installation_mode = "force_installed";
            }
          );
        in
        {
          AutofillAddressEnabled = true;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableFeedbackCommands = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          OfferToSaveLogins = false;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          ExtensionSettings = mkExtensionSettings {
            "{74145f27-f039-47ce-a470-a662b129930a}" = "clearurls";
            "jid1-BoFifL9Vbdl2zQ@jetpack" = "decentraleyes";
            "uBlock0@raymondhill.net" = "ublock-origin";
            "{d634138d-c276-4fc8-924b-40a0ea21d284}" = "1password-x-password-manager";
            "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = "vimium-ff";
            "clipper@obsidian.md" = "web-clipper-obsidian";
          };
          Preferences = mkLockedAttrs {
            "browser.aboutConfig.showWarning" = false;
            "browser.tabs.warnOnClose" = false;
            "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
            "browser.gesture.swipe.left" = "";
            "browser.gesture.swipe.right" = "";
            "browser.tabs.hoverPreview.enabled" = true;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.topsites.contile.enabled" = false;

            "privacy.resistFingerprinting" = true;
            # cookieBehavior = 5 (Total Cookie Protection) is the modern replacement
            # for firstparty.isolate — enabling both causes SSO/login breakage.
            "network.cookie.cookieBehavior" = 5;
            "dom.battery.enabled" = false;

            "gfx.webrender.all" = true;
            "network.http.http3.enabled" = true;

            # Prevent keystrokes in the URL bar from being sent to the search engine
            "browser.search.suggest.enabled" = false;
            "browser.urlbar.suggest.searches" = false;
            "browser.urlbar.speculativeConnect.enabled" = false;
          };
        };

      profiles.default =
        let
          containers = {
            Corpo = {
              color = "blue";
              icon = "briefcase";
              id = 1;
            };
            Shopping = {
              color = "yellow";
              icon = "dollar";
              id = 2;
            };
          };
        in
        {
          settings = {
            "zen.workspaces.continue-where-left-off" = true;
            "zen.workspaces.natural-scroll" = true;
            "zen.view.compact.hide-tabbar" = true;
            "zen.view.compact.hide-toolbar" = true;
            "zen.view.compact.animate-sidebar" = true;
          };

          bookmarks = {
            force = true;
            settings = [
              {
                name = "Nix sites";
                toolbar = true;
                bookmarks = [
                  {
                    name = "nixvim";
                    tags = [
                      "nix"
                      "nvim"
                    ];
                    url = "https://nix-community.github.io/nixvim/";
                  }
                ];
              }
            ];
          };

          containersForce = true;
          inherit containers;

          search = {
            force = true;
            default = "startpage";
            engines =
              let
                nixSnowflakeIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              in
              {
                "Startpage" = {
                  urls = [
                    {
                      template = "https://www.startpage.com/sp/search";
                      params = [
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  definedAliases = [ "sp" ];
                };
                "Nix Packages" = {
                  urls = [
                    {
                      template = "https://search.nixos.org/packages";
                      params = [
                        {
                          name = "type";
                          value = "packages";
                        }
                        {
                          name = "channel";
                          value = "unstable";
                        }
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = nixSnowflakeIcon;
                  definedAliases = [ "np" ];
                };
                "Nix Options" = {
                  urls = [
                    {
                      template = "https://search.nixos.org/options";
                      params = [
                        {
                          name = "channel";
                          value = "unstable";
                        }
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = nixSnowflakeIcon;
                  definedAliases = [ "nop" ];
                };
                "Home Manager Options" = {
                  urls = [
                    {
                      template = "https://home-manager-options.extranix.com/";
                      params = [
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                        {
                          name = "release";
                          value = "master";
                        }
                      ];
                    }
                  ];
                  icon = nixSnowflakeIcon;
                  definedAliases = [ "hmop" ];
                };
                bing.metaData.hidden = "true";
                google.metaData.hidden = "true";
              };
          };
        };
    };
  };
}
