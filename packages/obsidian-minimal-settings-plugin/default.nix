{ pkgs, ... }:
let
  version = "9.0.0";
  hashes = {
    "main.js" = "sha256-91TgzmUj5DO/+OeZWoSPfX+sIFOZ+as7ElhDAmH9kMQ=";
    "manifest.json" = "sha256-IDj5wfXKAm68Hz4Va62XxnHSxAGiBxg4RQjvcgcejF8=";
    "styles.css" = "sha256-UAhHYNqSelv1rBudO5YNxS4dCjv2kOVN+PTXb4ISYow=";
  };
  fetch =
    name:
    pkgs.fetchurl {
      inherit name;
      url = "https://github.com/kepano/obsidian-minimal-settings/releases/download/${version}/${name}";
      hash = hashes.${name};
    };
in
pkgs.runCommandLocal "obsidian-minimal-settings-${version}" { } ''
  mkdir -p $out
  cp ${fetch "main.js"}        $out/main.js
  cp ${fetch "manifest.json"}  $out/manifest.json
  cp ${fetch "styles.css"}     $out/styles.css
''
