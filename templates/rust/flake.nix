{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs { inherit system overlays; };
        in
        {
          # Default shell with stable Rust
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Rust toolchain (latest stable)
              rust-bin.stable.latest.default

              # Development tools
              rust-analyzer

              # Optional: Additional cargo tools
              # cargo-watch      # Auto-rebuild on file changes
              # cargo-edit       # cargo add, cargo rm, cargo upgrade
              # cargo-audit      # Security vulnerability scanner
              # cargo-bloat      # Find what takes space in binary
            ];

            shellHook = ''
              echo "🦀 Rust development environment"
              echo "Rust version: $(rustc --version)"
              echo "Cargo version: $(cargo --version)"
            '';
          };

          # Alternative: Specific Rust version
          rust-1-91 = pkgs.mkShell {
            packages = with pkgs; [
              rust-bin.stable."1.91.0".default
              rust-analyzer
            ];
          };

          # Alternative: Nightly Rust
          nightly = pkgs.mkShell {
            packages = with pkgs; [
              rust-bin.nightly.latest.default
              rust-analyzer
            ];
          };
        }
      );
    };
}
