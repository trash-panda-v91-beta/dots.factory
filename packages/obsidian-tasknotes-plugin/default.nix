{ pkgs, inputs, ... }:
let
  fetch =
    name: pin:
    pkgs.fetchurl {
      inherit name;
      url = pin.url;
      hash = pin.hash;
    };
  manifest = fetch "manifest.json" inputs.obsidian-tasknotes-manifest;
  version = (builtins.fromJSON (builtins.readFile manifest)).version;
in
pkgs.runCommandLocal "tasknotes-${version}" { } ''
  mkdir -p $out
  cp ${fetch "main.js"      inputs.obsidian-tasknotes-main}     $out/main.js
  cp ${manifest}                                                 $out/manifest.json
  cp ${fetch "styles.css"   inputs.obsidian-tasknotes-styles}   $out/styles.css
''
