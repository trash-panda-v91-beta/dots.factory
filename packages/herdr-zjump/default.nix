{
  lib,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "herdr-zjump";
  version = "0.1.0";

  src = ./.;

  dontBuild = true;

  # `herdr plugin link $out` reads $out/herdr-plugin.toml and runs the scripts
  # by relative path with $out as their cwd. jq / zoxide / herdr resolve from
  # the user's PATH at runtime.
  installPhase = ''
    mkdir -p $out
    install -Dm644 herdr-plugin.toml $out/herdr-plugin.toml
    install -Dm755 jump.sh           $out/jump.sh
    install -Dm755 worktree-event.sh $out/worktree-event.sh
    install -Dm755 apply-layout.sh   $out/apply-layout.sh
  '';

  meta = {
    description = "Sesh-style zoxide jumper + auto nvim/pi/sh tab layout for herdr";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
