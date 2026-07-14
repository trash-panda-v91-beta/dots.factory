{ pkgs, ... }:
let
  version = "4.11.1";
  base = "https://github.com/callumalpass/tasknotes/releases/download/${version}";
in
pkgs.runCommandLocal "tasknotes-${version}" { } ''
  mkdir -p $out
  cp ${
    pkgs.fetchurl {
      url = "${base}/main.js";
      hash = "sha256-7wJ4xNGTKby0ru/QV5zv8Ke8jx8cE7DcPOScVoHzqps=";
    }
  } $out/main.js
  cp ${
    pkgs.fetchurl {
      url = "${base}/manifest.json";
      hash = "sha256-z0Uu01gM+3tM+5U6y+toVNjbQLPzj3M9pPG25u85B34=";
    }
  } $out/manifest.json
  cp ${
    pkgs.fetchurl {
      url = "${base}/styles.css";
      hash = "sha256-+wJunr6pAu+u5Sy6ckHlkLRIUApyBXuBn/gIouRyYJ8=";
    }
  } $out/styles.css
''
