{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.aichat;
  yaml = pkgs.formats.yaml { };
  aiChatConfig = {
    stream = false;
    inherit (cfg) model;
    clients = [
      {
        type = "openai-compatible";
        name = "copilot";
        api_base = "https://api.githubcopilot.com";
        patch = {
          chat_completions = {
            ".*" = {
              headers = {
                "Copilot-Integration-Id" = "vscode-chat";
                "Editor-Version" = "aichat/0.1.0";
              };
            };
          };
        };
      }
    ];
  };
in
{
  options.modules.aichat = {
    enable = lib.mkEnableOption "aichat";
    model = lib.mkOption {
      type = lib.types.str;
      default = "copilot:claude-3.7-sonnet";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      unstable.aichat
    ];
    xdg.configFile."aichat/config.yaml" = {
      source = yaml.generate "config.yaml" aiChatConfig;
      enable = true;
    };
  };
}
