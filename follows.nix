inputs: {
  # nixpkgs-lib is a subset of nixpkgs — alias it to avoid a separate fetch
  nixpkgs-lib.follows = "nixpkgs";

  # Shim nix-systems/default — nixvim does: systems = import inputs.systems
  # Must be an importable path returning a list of system strings.
  systems = builtins.toFile "systems.nix"
    (builtins.concatStringsSep "\n" (
      [ "[" ]
      ++ (map (s: "  \"${s}\"") inputs.nixpkgs.lib.systems.flakeExposed)
      ++ [ "]" ]
    ));

  # Pin name aliases — npins uses dots, modules use hyphens
  # Add shortRev (= first 7 chars of revision) since packages use inputs.*.shortRev
  "koda-nvim" = let src = inputs."koda.nvim"; in src // { shortRev = builtins.substring 0 7 src.revision; };
  "opencode-nvim" = let src = inputs."opencode.nvim"; in src // { shortRev = builtins.substring 0 7 src.revision; };

  # zen-browser pin is named "zen-browser-flake" in npins; modules use inputs.zen-browser
  zen-browser.follows = "zen-browser-flake";

  # Standard follows to reduce duplication
  darwin.inputs.nixpkgs.follows = "nixpkgs";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
  nix-homebrew.inputs.brew-src.follows = "brew-src";
  sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  zen-browser.inputs.home-manager.follows = "home-manager";
}
