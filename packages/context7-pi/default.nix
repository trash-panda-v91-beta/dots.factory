{
  lib,
  stdenvNoCC,
  bun,
  inputs,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "context7-pi";
  version = inputs.context7-pi.shortRev;

  src = inputs.context7-pi;

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
}
