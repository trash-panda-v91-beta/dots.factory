{
  lib,
  stdenvNoCC,
  bun,
  cacert,
  inputs,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "pi-lsp";
  version = inputs.pi-lsp.shortRev;

  src = inputs.pi-lsp;

  nativeBuildInputs = [ bun cacert ];

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-rUFD9wTyDZiPF31xU8rCa7NZhCMalsCXmxKQO9QBS2Q=";

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR/home
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    mkdir -p "$HOME"

    # Remove npm lockfile so bun doesn't try to migrate + freeze it
    rm -f package-lock.json

    bun install --production --ignore-scripts
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
