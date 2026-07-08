{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "herdr-splits";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "lmilojevicc";
    repo = "herdr-splits.nvim";
    rev = "167641719f364e6bd9866f584df8a210f7d7bfd2";
    hash = "sha256-l+EpgPsa1MF584W5/b3OZVDrUZlXxqORrJxpIMmrrRk=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/scripts
    install -Dm644 herdr-plugin.toml  $out/herdr-plugin.toml
    install -Dm755 scripts/herdr-nav.sh    $out/scripts/herdr-nav.sh
    install -Dm755 scripts/herdr-resize.sh $out/scripts/herdr-resize.sh
  '';

  meta = {
    description = "Herdr-side plugin for seamless Neovim split / Herdr pane navigation";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
