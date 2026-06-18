{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  ...
}:
let
  rev = "cb6aee187eee81f4d9b0521fc61ef5d058d2535a";
  package = stdenvNoCC.mkDerivation {
    pname = "context7-pi";
    version = "0.1.0";

    src = fetchFromGitHub {
      owner = "upstash";
      repo = "context7";
      inherit rev;
      hash = "sha256-heLV/QLv6zDt5e1Qiel9JOEqUmIX2ifgMzqhCkMejuA=";
    };

    nativeBuildInputs = [ bun ];

    buildPhase = ''
      runHook preBuild

      bun build packages/pi/extensions/context7.ts \
        --target=node \
        --format=esm \
        --outfile=context7.js \
        --external='@earendil-works/*' \
        --external=typebox

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp context7.js $out/
      cp -r packages/pi/skills $out/
      cp -r packages/pi/prompts $out/
      runHook postInstall
    '';

    meta = {
      description = "Official Context7 extension for Pi coding agent";
      homepage = "https://github.com/upstash/context7";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  };
in
package
