{
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
    editor = {
      nvim = {
        enable = true;
        makeDefaultEditor = true;
      };
    };
    fd.enable = true;
    fzf = {
      enable = true;
    };
    karabiner-config.enable = true;

    raycast.enable = true;

    security = {
      ssh = {
        enable = true;
      };
    };

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
  };
}
