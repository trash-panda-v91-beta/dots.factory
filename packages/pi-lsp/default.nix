{
  lib,
  stdenvNoCC,
  bun,
  inputs,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "pi-lsp";
  version = inputs.pi-lsp.shortRev;

  src = inputs.pi-lsp;

  nativeBuildInputs = [ bun ];

  buildPhase = ''
    runHook preBuild

    bun build extensions/pi-lsp/src/pi-lsp.ts \
      --target=node \
      --format=esm \
      --outfile=pi-lsp.js \
      --external='@earendil-works/*' \
      --external=typebox

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp pi-lsp.js $out/
    runHook postInstall
  '';

  meta = {
    description = "Configurable LSP diagnostics and fix tools for Pi coding agent";
    homepage = "https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-lsp";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
