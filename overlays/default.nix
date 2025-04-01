{ inputs, ... }:
{

  additions =
    final: _prev:
    import ../pkgs {
      inherit inputs;
      pkgs = final;
    };

  # The unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through `pkgs.unstable`
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [
        # overlays of unstable packages are declared here
        (_final: prev: {
          tmuxPlugins = prev.tmuxPlugins // {
            catppuccin = prev.tmuxPlugins.catppuccin.overrideAttrs (oldAttrs: {
              postInstall =
                (oldAttrs.postInstall or "")
                + ''
                  cat >> $out/share/tmux-plugins/catppuccin/themes/catppuccin_cyberdream_tmux.conf << 'END'
                  # vim:set ft=tmux:

                  # --> Catppuccin (Frappe)
                  set -ogq @thm_bg "#1e2124"
                  set -ogq @thm_fg "#ffffff"

                  # Colors
                  set -ogq @thm_rosewater "#5ef1ff"
                  set -ogq @thm_flamingo "#ff5ef1"
                  set -ogq @thm_pink "#ff5ea0"
                  set -ogq @thm_mauve "#ff5ef1"
                  set -ogq @thm_red "#ff6e5e"
                  set -ogq @thm_maroon "#ff6e5e"
                  set -ogq @thm_peach "#ffbd5e"
                  set -ogq @thm_yellow "#f1ff5e"
                  set -ogq @thm_green "#5eff6c"
                  set -ogq @thm_teal "#5ef1ff"
                  set -ogq @thm_sky "#5ea1ff"
                  set -ogq @thm_sapphire "#5ea1ff"
                  set -ogq @thm_blue "#5ea1ff"
                  set -ogq @thm_lavender "#ff5ef1"

                  # Surfaces and overlays
                  set -ogq @thm_subtext_1 "#7b8496"
                  set -ogq @thm_subtext_0 "#7b8496"
                  set -ogq @thm_overlay_2 "#3c4048"
                  set -ogq @thm_overlay_1 "#3c4048"
                  set -ogq @thm_overlay_0 "#3c4048"
                  set -ogq @thm_surface_2 "#3c4048"
                  set -ogq @thm_surface_1 "#3c4048"
                  set -ogq @thm_surface_0 "#3c4048"
                  set -ogq @thm_mantle "#1e2124"
                  set -ogq @thm_crust "#1e2124"
                  END
                '';
            });
          };
        })
      ];
    };
  };

  nixpkgs-overlays = _final: prev: {
    _1password-gui = prev._1password-gui.override { polkitPolicyOwners = inputs.nixpkgs.lib.users; };
    # services.karabiner-elements is broken after Karabiner-Elements v15.0
    # https://github.com/LnL7/nix-darwin/issues/1041
    karabiner-elements = prev.karabiner-elements.overrideAttrs (oldAttrs: {
      version = "14.13.0";
      src = prev.fetchurl {
        inherit (oldAttrs.src) url;
        hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
      };
    });
  };
}
