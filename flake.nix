{
  outputs =
    flakeInputs:
    let
      # Sources that used to live as `flake = false` inputs now come from
      # npins (see npins/sources.json). This adapts each to look like a flake
      # input (adds `shortRev`) and merges into `inputs`, so any existing
      # `inputs.pi-web-access` etc. code keeps working.
      npinsSources = import ./npins;
      pinNames = builtins.filter (n: n != "__functor") (builtins.attrNames npinsSources);
      asFlakeInput =
        src:
        src
        // {
          shortRev = builtins.substring 0 7 (src.revision or src.rev or "0000000");
        };
      npinsAsInputs = builtins.listToAttrs (
        map (n: {
          name = n;
          value = asFlakeInput npinsSources.${n};
        }) pinNames
      );
      inputs = flakeInputs // npinsAsInputs;
    in
    flakeInputs.flake-parts.lib.mkFlake { inherit inputs; } (flakeInputs.import-tree ./modules);

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.brew-src.follows = "brew-src";
    };
    brew-src = {
      url = "github:Homebrew/brew/6.0.15";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    vicinae.url = "github:vicinaehq/vicinae";

    den.url = "github:vic/den/v0.18.0";
    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
    };
    systems.url = "github:nix-systems/aarch64-darwin";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Sources pinned via npins (not flake inputs): koda-nvim, pi-nvim,
    # opencode-nvim, context7-pi, pi-lsp, pi-mcp-adapter, ponytail,
    # pi-web-access, pi-neuralwatt.
    # Update those with `npins update <name>` (or `mise run update`).

    # CMB — private repo (corp host).
    # PMB builds: nixpkgs has no flakeModules → corpo.nix guard returns [].
    # CMB builds: --override-input corpo path:../dots.corpo
    corpo.follows = "nixpkgs";
  };
}
