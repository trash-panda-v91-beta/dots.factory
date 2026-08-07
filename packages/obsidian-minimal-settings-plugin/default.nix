{ pkgs, ... }:
let
  version = "9.0.0";
  base = "https://github.com/kepano/obsidian-minimal-settings/releases/download/${version}";
in
pkgs.runCommandLocal "obsidian-minimal-settings-${version}" { } ''
  mkdir -p $out
  cp ${
    pkgs.fetchurl {
      url = "${base}/main.js";
      hash = "sha256-91TgzmUj5DO/+OeZWoSPfX+sIFOZ+as7ElhDAmH9kMQ=";
    }
  } $out/main.js
  cp ${
    pkgs.fetchurl {
      url = "${base}/manifest.json";
      hash = "sha256-IDj5wfXKAm68Hz4Va62XxnHSxAGiBxg4RQjvcgcejF8=";
    }
  } $out/manifest.json
  cp ${
    pkgs.fetchurl {
      url = "${base}/styles.css";
      hash = "sha256-UAhHYNqSelv1rBudO5YNxS4dCjv2kOVN+PTXb4ISYow=";
    }
  } $out/styles.css
''
