{ pkgs, ... }:
let
  version = "8.2.3";
  base = "https://github.com/kepano/obsidian-minimal-settings/releases/download/${version}";
in
pkgs.runCommandLocal "obsidian-minimal-settings-${version}" { } ''
  mkdir -p $out
  cp ${
    pkgs.fetchurl {
      url = "${base}/main.js";
      hash = "sha256-iqk1CXf8oJj1bOpETrZylC4Q/K65sHrOsFo9U2iqdCs=";
    }
  } $out/main.js
  cp ${
    pkgs.fetchurl {
      url = "${base}/manifest.json";
      hash = "sha256-FoKjO20Rf0gVpFKzVbUJAYeqwF7m6quPDoN3s6ecRFM=";
    }
  } $out/manifest.json
  cp ${
    pkgs.fetchurl {
      url = "${base}/styles.css";
      hash = "sha256-UAhHYNqSelv1rBudO5YNxS4dCjv2kOVN+PTXb4ISYow=";
    }
  } $out/styles.css
''
