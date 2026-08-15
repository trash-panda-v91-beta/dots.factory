{ pkgs, ... }:
let
  version = "4.12.3";
  base = "https://github.com/callumalpass/tasknotes/releases/download/${version}";
in
pkgs.runCommandLocal "tasknotes-${version}" { } ''
  mkdir -p $out
  cp ${
    pkgs.fetchurl {
      url = "${base}/main.js";
      hash = "sha256-eHZMCaZN5pGOnWESJ55yzPvK7OIY+WF1hTTrp5Z4RqE=";
    }
  } $out/main.js
  cp ${
    pkgs.fetchurl {
      url = "${base}/manifest.json";
      hash = "sha256-/OyoRG1DY3jIcMh/NEsJmKog9xm8zvgrovr0JmifB7A=";
    }
  } $out/manifest.json
  cp ${
    pkgs.fetchurl {
      url = "${base}/styles.css";
      hash = "sha256-tnHJ6Da8Dw8hGH/Z5+6lP4TXW2mg/4RJJBIiAGKXp8Y=";
    }
  } $out/styles.css
''
