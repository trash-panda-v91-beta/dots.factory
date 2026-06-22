{ pkgs, ... }:
let
  version = "4.11.0";
  base = "https://github.com/callumalpass/tasknotes/releases/download/${version}";
in
pkgs.runCommandLocal "tasknotes-${version}" { } ''
  mkdir -p $out
  cp ${
    pkgs.fetchurl {
      url = "${base}/main.js";
      hash = "sha256-cRA/hobFaxJmQKcgKHrMya5MUdjYfHSmVwrBQcIA3mw=";
    }
  } $out/main.js
  cp ${
    pkgs.fetchurl {
      url = "${base}/manifest.json";
      hash = "sha256-OJQABjT1NutKjgOwmtjZu+iKvjG6u3JtbxvExtHS2iE=";
    }
  } $out/manifest.json
  cp ${
    pkgs.fetchurl {
      url = "${base}/styles.css";
      hash = "sha256-ZQOfFZkVcXvPAW60T87TR4cDrEa932xkIwhl2caqJqY=";
    }
  } $out/styles.css
''
