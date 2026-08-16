{ pkgs, inputs, ... }:
let
  fetch =
    name: pin:
    pkgs.fetchurl {
      inherit name;
      url = pin.url;
      hash = pin.hash;
    };
  manifest = fetch "manifest.json" inputs.obsidian-minimal-settings-manifest;
  version = (builtins.fromJSON (builtins.readFile manifest)).version;
in
pkgs.runCommandLocal "obsidian-minimal-settings-${version}" { } ''
  mkdir -p $out
  cp ${fetch "main.js"    inputs.obsidian-minimal-settings-main}     $out/main.js
  cp ${manifest}                                                      $out/manifest.json
  cp ${fetch "styles.css" inputs.obsidian-minimal-settings-styles}   $out/styles.css
''
