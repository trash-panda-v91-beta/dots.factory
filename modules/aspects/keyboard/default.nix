{ ... }:
{
  dots.keyboard = {
    description = "Kanata keyboard remapper (Arsenik layout)";

    includes = [
      { darwin.imports = [ ./_kanata-module.nix ]; }
    ];

    darwin =
      { pkgs, ... }:
      {
        services.kanata = {
          enable = true;
          package = pkgs.kanata;
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
