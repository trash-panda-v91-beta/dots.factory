{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.aichat;
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
      default = "copilot:gpt-4o";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      unstable.aichat
    ];
    xdg.configFile."aichat/config.yaml".text = lib.generators.toYAML {} aiChatConfig;
  };
}
