{ ... }:
{
  dots.tool._.keyboard = {
    description = "Kanata keyboard remapper (Arsenik layout)";

    includes = [
      { darwin.imports = [ ./_kanata-module.nix ]; }
    ];

    darwin =
      { pkgs, ... }:
      {
        services.kanata = {
          enable = true;
          package =
            let
              kanata-src = pkgs.fetchFromGitHub {
                owner = "jtroo";
                repo = "kanata";
                rev = "v1.12.0";
                hash = "sha256-WjdmjgEMoo3QNqT4yWxaKOkfuRLdNg4Im+V1Hy5vWgY=";
              };
            in
            (pkgs.kanata.override { withCmd = true; }).overrideAttrs (_: {
              version = "1.12.0";
              src = kanata-src;
              cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
                src = kanata-src;
                hash = "sha256-4UBN4I35ZPPPL68LxxPna9Fs9sATCiwoTbWgHYwqOjs=";
              };
            });
          keyboards.internal = {
            config =
              let
                a = ./kanata/arsenik;
              in
              ''
                (defvar
                  tap_timeout 200
                  hold_timeout 200
                  long_hold_timeout 300
                )

                (include ${a}/defsrc/mac.kbd)
                (include ${a}/deflayer/base_lt_hrm.kbd)
                (include ${a}/deflayer/symbols_lafayette_num.kbd)
                (include ${a}/deflayer/navigation_vim.kbd)
                (include ${a}/defalias/qwerty_mac.kbd)
              '';
            extraDefCfg = ''
              process-unmapped-keys yes
              windows-altgr cancel-lctl-press
              danger-enable-cmd yes
            '';
          };
        };
      };

    homeManager.programs.nushell.shellAliases = {
      restart-kanata = "sudo launchctl kickstart -k system/org.nixos.kanata-internal";
      kanata-logs = "tail -f /var/log/kanata-internal.err.log /var/log/kanata-internal.out.log";
    };
  };
}
