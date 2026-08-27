{
  lib,
  stdenvNoCC,
  bun,
  cacert,
  inputs,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "pi-mcp-adapter";
  version = inputs.pi-mcp-adapter.shortRev;

  src = inputs.pi-mcp-adapter;

  nativeBuildInputs = [
    bun
    cacert
  ];

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-IfbdKOyPiUngl0cpd4xs/+ektPesdt1QKIbf0Q2V5dw=";

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR/home
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    mkdir -p "$HOME"

    # Use our committed lock, not the source's npm lock (bun re-migrates it and drifts).
    rm -f package-lock.json pnpm-lock.yaml
    cp ${./bun.lock} bun.lock
    bun install --ignore-scripts
    bun build index.ts \
      --target=node \
      --format=esm \
      --outfile=index.js \
      --external='@earendil-works/*' \
      --external=typebox

    # The bundle embeds the build dir ($PWD), which differs per build/machine;
    # normalize it so the FOD hash is identical on every host.
    sed "s|$PWD|/bundle|g" index.js > index.js.tmp && mv index.js.tmp index.js

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp index.js $out/
    runHook postInstall
  '';

  meta = {
    description = "MCP adapter extension for Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
