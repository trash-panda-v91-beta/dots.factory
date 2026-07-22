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

  nativeBuildInputs = [ bun cacert ];

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-6B9Be1FUAhoJ//SgOMhjccaEq4CfwSN5ZqzOxDxsOBw=";

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR/home
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    mkdir -p "$HOME"

    bun install --production --ignore-scripts
    bun build index.ts \
      --target=node \
      --format=esm \
      --outfile=index.js \
      --external='@earendil-works/*' \
      --external=typebox

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
