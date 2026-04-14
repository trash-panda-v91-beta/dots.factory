{ pkgs, ... }:
pkgs.fetchFromGitHub {
  owner = "kepano";
  repo = "obsidian-minimal";
  rev = "8.1.7";
  hash = "sha256-rpqFtbHV1xceioeykivi/2b93QrkZzTl4H+jaX35ERY=";
}
