{
  config,
  inputs,
  hostname,
  ...
}:
{
  imports = [
    ../_modules
    ./hosts/${hostname}.nix
  ];

  modules = {
    aichat.enable = false;
    editor = {
      nvim = {
        enable = true;
        makeDefaultEditor = true;
        aiProvider = {
          name = "copilot";
          model = "claude-3.7-sonnet";
        };
      };
    };
    fd.enable = true;
    fzf = {
      enable = true;
    };
    karabiner-config.enable = true;

    hammerspoon-config.enable = true;
    raycast.enable = true;
    # TODO: fix build
    run-on-unlock.enable = false;
    security = {
      ssh = {
        enable = true;
      };
    };

    rust-development.enable = true;
    shell = {
      atuin = {
        enable = false;
      };
      aws = {
        enable = true;
      };
      fish.enable = true;

      git = {
        enable = true;
        inherit (inputs.secrets.corporate) username;
        inherit (inputs.secrets.corporate) email;
        services = {
          "${inputs.secrets.corporate.gitUrl}" = "github:${inputs.secrets.corporate.gitUrl}";
        };
      };

      go-task.enable = true;
      yamlfmt.enable = true;
      yamllint.enable = true;
      tmux.enable = true;
    };
    virtualisation = {
      docker-cli = {
        enable = true;
      };
      colima = {
        enable = true;
        startService = true;
      };
    };
    themes = {
      cyberdream = {
        enable = true;
      };
    };
    zk = {
      enable = true;
      default_directory = "${config.home.homeDirectory}/notes";
    };
  };
}
