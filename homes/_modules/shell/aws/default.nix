{ config, lib, ... }:
let
  cfg = config.modules.shell.aws;
in
{
  options.modules.shell.aws = {
    enable = lib.mkEnableOption "aws";
    region = lib.mkOption {
      type = lib.types.str;
      default = "us-west-2";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs = {
        awscli = {
          enable = true;
          settings = {
            "default" = {
              inherit (cfg) region;
              output = "json";
            };
          };
        };
        fish = {
          shellAbbrs = {
            aa = "aws_okta_keyman";
          };
        };
      };
      home.sessionVariables = {
        AWS_DEFAULT_REGION = cfg.region;
      };
    })
  ];
}
