{ pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      any-nix-shell
      binutils
      coreutils
      curl
      du-dust
      envsubst
      findutils
      fish
      gawk
      gnused
      gum
      jo
      jq
      vim
      wget
      yq-go
    ];
  };
}
