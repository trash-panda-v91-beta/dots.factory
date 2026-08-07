{ pkgs, ... }:
pkgs.fetchFromGitHub {
  owner = "kepano";
  repo = "obsidian-minimal";
  rev = "9.0.2";
  hash = "sha256-9ASmzalN8xcwQHi8uarVZ9IHXlb6QLn7AE2jUcAvdyM=";
}
