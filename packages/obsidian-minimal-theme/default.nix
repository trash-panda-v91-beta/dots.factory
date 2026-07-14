{ pkgs, ... }:
pkgs.fetchFromGitHub {
  owner = "kepano";
  repo = "obsidian-minimal";
  rev = "8.2.1";
  hash = "sha256-iqDHM19S244YCT1IaHmeJsW/k0FbXqIH5Tww0LqV+ZA=";
}
