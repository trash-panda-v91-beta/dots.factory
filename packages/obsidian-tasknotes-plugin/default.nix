{ pkgs, ... }:
let
  version = "4.5.1";
  base = "https://github.com/callumalpass/tasknotes/releases/download/${version}";
in
pkgs.runCommandLocal "tasknotes-${version}" { } ''
  mkdir -p $out
  cp ${
    pkgs.fetchurl {
      url = "${base}/main.js";
      hash = "sha256-L2fixwyvE7Ik1iAMtmHznuuHnEfo4y9YNXiph1OiT5k=";
    }
  } $out/main.js
  cp ${
    pkgs.fetchurl {
      url = "${base}/manifest.json";
      hash = "sha256-/1P8iZQSnMIVEor+jhpOKUwta0VYciVWw4ImaY7yp00=";
    }
  } $out/manifest.json
  cp ${
    pkgs.fetchurl {
      url = "${base}/styles.css";
      hash = "sha256-rW45VnOTuWu1NgyjOShw4e9XK8NcsZEsGlqzHFv9aWY=";
    }
  } $out/styles.css
''
