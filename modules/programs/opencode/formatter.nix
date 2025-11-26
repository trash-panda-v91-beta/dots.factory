{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.opencode.formatter";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.opencode.settings.formatter = {
      nixfmt = {
        command = [
          (pkgs.lib.getExe pkgs.nixfmt)
          "$FILE"
        ];
        extensions = [ ".nix" ];
      };

      rustfmt = {
        command = [
          (pkgs.lib.getExe pkgs.rustfmt)
          "$FILE"
        ];
        extensions = [ ".rs" ];
      };
    };
  };
}
