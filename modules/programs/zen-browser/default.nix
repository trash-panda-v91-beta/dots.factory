{
  delib,
  inputs,
  pkgs,
  ...
}:
delib.module {
  name = "programs.zen-browser";

  options = delib.singleEnableOption false;

  home.always.imports = [
    # ../../../extra/zen-browser.nix {inhert inputs.home-manager;}
  ];

  home.ifEnabled = {
    programs.zen-browser = {
      enable = true;
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
            "{d634138d-c276-4fc8-924b-40a0ea21d284}" = "1password";
            # "" = "vimium";
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
            "privacy.firstparty.isolate" = true;
            "network.cookie.cookieBehavior" = 5;
            "dom.battery.enabled" = false;

            "gfx.webrender.all" = true;
            "network.http.http3.enabled" = true;
          };
        };

      profiles.default =
        let
          containers = {
            Work = {
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
            "zen.view.compact.animate-sidebar" = false;
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
            default = "google";
            engines =
              let
                nixSnowflakeIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              in
              {
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
                          value = "master"; # unstable
                        }
                      ];
                    }
                  ];
                  icon = nixSnowflakeIcon;
                  definedAliases = [ "hmop" ];
                };
                bing.metaData.hidden = "true";
              };
          };
        };
    };
  };
}
