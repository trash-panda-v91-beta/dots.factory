{ pkgs, ... }:
{
  config = {
    programs.bat = {
      enable = true;
    };

    programs.fish = {
      shellAliases = {
        cat = "bat";
      };
    };
  };
}
