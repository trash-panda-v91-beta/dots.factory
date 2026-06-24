# Platform bundle - macOS system-level concerns
# Included on hosts. Everything here writes to the darwin/nixos class.
{ __findFile, ... }:
{
  dots.bundle._.platform = {
    description = "System-level platform: nix daemon, darwin defaults, homebrew, library hooks, overlays";
    includes = [
      <dots/platform/nix>
      <dots/platform/darwin-system>
      <dots/platform/homebrew>
      <dots/platform/library-linking>
      <dots/platform/overlays>
    ];
  };
}
