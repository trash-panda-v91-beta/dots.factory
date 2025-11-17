{ delib, ... }:
delib.overlayModule {
  name = "fish";
  overlay = final: prev: {
    fish = prev.fish.overrideAttrs (oldAttrs: {
      # TODO: remove after https://github.com/NixOS/nixpkgs/pull/462090 getting through staging
      doCheck = !prev.stdenv.hostPlatform.isDarwin;
    });
  };
}
