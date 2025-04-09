{ pkgs, ... }:
{
  imports = [
    ./mutability.nix
    ./secrets.nix

    ./browsers
    ./desktop
    ./deployment
    ./editor
    ./fd
    ./fzf
    ./hammerspoon-config
    ./karabiner-config
    ./kbs
    ./kubernetes
    ./security
    ./raycast
    ./run-on-unlock
    ./shell
    ./terminals
    ./themes
    ./virtualisation
  ];

  config = {
    home.stateVersion = "23.11";

    programs = {
      home-manager.enable = true;
    };

    xdg.enable = true;

    home.packages = [ pkgs.home-manager ];
  };
}
