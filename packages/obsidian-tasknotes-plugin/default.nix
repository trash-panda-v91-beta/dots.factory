{ pkgs, ... }:
let
  version = "4.13.10";
  hashes = {
    "main.js" = "sha256-D0Ttwni9MArIwG0ePYMWoIEFrAY+jVeoTEURVfV92XY=";
    "manifest.json" = "sha256-S0PjEXwBBZGX+sU1CBERdLkqm5tZjyOqZmU7A5JCzZw=";
    "styles.css" = "sha256-o65nTLg/52KcTk3jqYfpnBRfR8c+SxaY6HmxL6Nzzl0=";
  };
  fetch =
    name:
    pkgs.fetchurl {
      inherit name;
      url = "https://github.com/callumalpass/tasknotes/releases/download/${version}/${name}";
      hash = hashes.${name};
    };
in
pkgs.runCommandLocal "tasknotes-${version}" { } ''
  mkdir -p $out
  cp ${fetch "main.js"}       $out/main.js
  cp ${fetch "manifest.json"}  $out/manifest.json
  cp ${fetch "styles.css"}     $out/styles.css
''
