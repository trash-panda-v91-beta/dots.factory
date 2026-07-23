{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

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
      url = "github:Homebrew/brew/5.1.7";
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

    den.url = "github:vic/den/v0.16.0";
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

    koda-nvim = {
      url = "github:oskarnurm/koda.nvim";
      flake = false;
    };
    pi-nvim = {
      url = "github:carderne/pi-nvim";
      flake = false;
    };
    opencode-nvim = {
      url = "github:sudo-tee/opencode.nvim";
      flake = false;
    };
    context7-pi = {
      # monorepo – tag @upstash/context7-pi@0.1.0 maps to this commit
      url = "github:upstash/context7/cb6aee187eee81f4d9b0521fc61ef5d058d2535a";
      flake = false;
    };
    pi-lsp = {
      url = "github:narumiruna/pi-extensions/v0.5.0";
      flake = false;
    };
    pi-mcp-adapter = {
      url = "github:nicobailon/pi-mcp-adapter/v2.11.0";
      flake = false;
    };
    ponytail = {
      url = "github:DietrichGebert/ponytail/v4.8.3";
      flake = false;
    };
    pi-web-access = {
      url = "github:nicobailon/pi-web-access/v0.10.7";
      flake = false;
    };
    pi-neuralwatt = {
      url = "github:aliou/pi-neuralwatt/v0.10.2";
      flake = false;
    };

    # CMB — private repo (corp host).
    # PMB builds: nixpkgs has no flakeModules → corpo.nix guard returns [].
    # CMB builds: --override-input corpo path:../dots.corpo
    corpo.follows = "nixpkgs";
  };
}
