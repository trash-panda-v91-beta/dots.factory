{
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
let
  cfg = config.${namespace}.suites.yaml;
in
{
  options.${namespace}.suites.yaml = {
    enable = lib.mkEnableOption "yaml";
  };
  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        yamlfmt
        yamllint
      ];
    };
    xdg.configFile."yamllint/config".text = ''
      extends: default

      rules:
        document-start: disable
    '';

    xdg.configFile."yamlfmt/.yamlfmt".text = ''
      formatter:
        type: basic
        disallow_anchors: false
        include_document_start: false
        retain_line_breaks: true
        drop_merge_tag: true
        indentless_arrays: false
        pad_line_comments: 2
    '';
  };
}

