{ pkgs, ... }:
let
  version = "4.12.0";
  base = "https://github.com/callumalpass/tasknotes/releases/download/${version}";
in
pkgs.runCommandLocal "tasknotes-${version}" { } ''
  mkdir -p $out
  cp ${
    pkgs.fetchurl {
      url = "${base}/main.js";
      hash = "sha256-LjK1YLqhzgkS3738KU3uVeNZb2zpOGHnUpVybNqQW/4=";
    }
  } $out/main.js
  cp ${
    pkgs.fetchurl {
      url = "${base}/manifest.json";
      hash = "sha256-tcKwqHy2kgZaRiVdvMbbf/48l0JKzGeRpm7OVN5sJ4M=";
    }
  } $out/manifest.json
  cp ${
    pkgs.fetchurl {
      url = "${base}/styles.css";
      hash = "sha256-MAEomdWrh860I/twcKgkBvGzpMQ+goG2k14xHTU+HaU=";
    }
  } $out/styles.css
''
