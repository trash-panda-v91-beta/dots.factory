{
  delib,
  moduleSystem,
  pkgs,
  ...
}:
delib.module {
  name = "services.kanata";

  options = delib.singleEnableOption (moduleSystem == "darwin");

  darwin.always.imports = [
    ../../../extra/services/kanata.nix
  ];

  darwin.ifEnabled = {
    # This way package is available in /run/current-system/sw/bin/
    environment.systemPackages = with pkgs; [
      kanata
    ];
    services.kanata = {
      enable = true;
      package = pkgs.kanata;
      keyboards.internal = {
        config = ''
          ;;==========================================================================;;
          ;;                                                                          ;;
          ;;  With Arsenik, choose the features you want for your keyboard:           ;;
          ;;  angle mods, Vim-like navigation layer, Mac/Azerty/Qwertz support, etc.  ;;
          ;;                                                                          ;;
          ;;==========================================================================;;

          ;; Every section is mandatory and should enable one and only one `include`
          ;; - enable each feature by un-commenting the related line.
          ;; - a commented line starts with ;;

          ;; Live-reload the configuration with Space+Backspace (requires layer-taps).

          ;; Timing variables for tap-hold effects.
          (defvar
            ;; The key must be pressed twice in 200ms to enable repetitions.
            tap_timeout 200
            ;; The key must be held 200ms to become a layer shift.
            hold_timeout 200
            ;; Slightly higher value for typing keys, to prevent unexpected hold effect.
            long_hold_timeout 300
          )

          ;;-----------------------------------------------------------------------------
          ;; Original key arrangement on your keyboard: Mac or PC.
          ;; Choose here if you want to add an angle mod: ZXCVB are shifted to the left.
          ;; See https://colemakmods.github.io/ergonomic-mods/angle.html for more details.

          ;; (include defsrc/pc.kbd)  ;; PC, standard finger assignment
             (include ${./arsenik/defsrc/mac.kbd})  ;; Mac, standard finger assignment
          ;; (include defsrc/pc_anglemod.kbd)  ;; PC, ZXCVB are shifted to the left
          ;; (include defsrc/mac_anglemod.kbd)  ;; Mac, ZXCVB are shifted to the left
          ;; (include defsrc/pc_wide_anglemod.kbd)  ;; PC, angle-mod + right hand shifted by one key
          ;; (include defsrc/mac_wide_anglemod.kbd)  ;; Mac, angle-mod + right hand shifted by one key


          ;;-----------------------------------------------------------------------------
          ;; `Base` layer: standard or dual keys? (layer-taps, homerow mods?)
          ;; If you just want angle mod, you still have to enable the standard base.

          ;; (include ${./arsenik/deflayer/base.kbd})  ;; standard keyboard behavior
          ;; (include ${./arsenik/deflayer/base_lt.kbd})  ;; layer-taps on both thumb keys
             (include ${./arsenik/deflayer/base_lt_hrm.kbd})  ;; layer-taps + home-row mods

          ;; Note: not enabling layer-taps here makes the rest of the file useless.


          ;;-----------------------------------------------------------------------------
          ;; `Symbols` layer

          ;; (include ${./arsenik/deflayer/symbols_noop.kbd})  ;; AltGr stays as-is
          ;; (include ${./arsenik/deflayer/symbols_lafayette.kbd})  ;; AltGr programmation layer like Ergo‑L
          ;; (include deflayer/symbols_noop_num.kbd)  ;; AltGr stays as-is + NumRow layers
             (include ${./arsenik/deflayer/symbols_lafayette_num.kbd})  ;; AltGr prog layer + NumRow layers

          ;;-----------------------------------------------------------------------------
          ;; `Navigation` layer: ESDF or HJKL?

          ;; (include ${./arsenik/deflayer/navigation.kbd})  ;; ESDF on the left, NumPad on the right
             (include ${./arsenik/deflayer/navigation_vim.kbd})  ;; HJKL + NumPad on [Space]+[Q]

          ;;-----------------------------------------------------------------------------
          ;; Aliases for `Symbols` and `Navigation` layers
          ;; Depends on PC/Mac and keyboard layout

          ;; (include ${./arsenik/defalias/ergol_pc.kbd})  ;; Ergo‑L PC
          ;; (include defalias/qwerty-lafayette_pc.kbd)  ;; Qwerty‑Lafayette PC
          ;; (include defalias/qwerty_pc.kbd)  ;; Qwerty / Colemak PC
          (include ${./arsenik/defalias/qwerty_mac.kbd})  ;; Qwerty / Colemak Mac
          ;; (include defalias/azerty_pc.kbd)  ;; Azerty PC
          ;; (include defalias/qwertz_pc.kbd)  ;; Qwertz PC
          ;; (include defalias/bepo_pc.kbd)  ;; Bépo PC
          ;; (include defalias/optimot_pc.kbd)  ;; Optimot PC

          ;;-----------------------------------------------------------------------------
        '';
        extraDefCfg = ''
          ;; Enabled makes kanata process keys that are not defined in defsrc
          process-unmapped-keys yes
          windows-altgr cancel-lctl-press
        '';
      };
    };
  };

  home.ifEnabled = {
    programs.nushell.shellAliases = {
      restart-kanata = "launchctl kickstart -k system/org.nixos.kanata-internal";
      kanata-logs = "tail -f /tmp/kanata-internal.err /tmp/kanata-internal.out";
    };
  };
}
