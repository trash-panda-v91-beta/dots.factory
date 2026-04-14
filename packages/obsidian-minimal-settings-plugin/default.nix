{ pkgs, ... }:
let
  version = "8.2.1";
  base = "https://github.com/kepano/obsidian-minimal-settings/releases/download/${version}";
in
pkgs.runCommandLocal "obsidian-minimal-settings-${version}" { } ''
  mkdir -p $out
  cp ${
    pkgs.fetchurl {
      url = "${base}/main.js";
      hash = "sha256-L2fmepJsNDupQY6rSMoZzoKCFtKhufrJdWAO04JgAMk=";
    }
  } $out/main.js
  cp ${
    pkgs.fetchurl {
      url = "${base}/manifest.json";
      hash = "sha256-TK+6P+2bcwyGyX7ss4Ce9VBHP+MxIwaG4fa99Ad15vM=";
    }
  } $out/manifest.json
  cp ${
    pkgs.fetchurl {
      url = "${base}/styles.css";
      hash = "sha256-UAhHYNqSelv1rBudO5YNxS4dCjv2kOVN+PTXb4ISYow=";
    }
  } $out/styles.css
''
