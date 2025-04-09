{
  pkgs,
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
    security = {
      ssh = {
        enable = true;
      };
    };
    raycast.enable = true;
    run-on-unlock.enable = true;
    shell = {
      atuin = {
        enable = true;
        package = pkgs.unstable.atuin;
        flags = [ "--disable-up-arrow" ];
        settings = {
          sync_address = "https://atuin.${inputs.secrets.domain}";
          key_path = config.sops.secrets.atuin_key.path;
          auto_sync = true;
          sync_frequency = "1m";
          search_mode = "fuzzy";
          sync = {
            records = true;
          };
        };
      };

      fish.enable = true;

      git = {
        enable = true;
        username = "aka-raccoon";
        email = "42897550+aka-raccoon@users.noreply.github.com";
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
