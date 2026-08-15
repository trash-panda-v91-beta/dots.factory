{
  lib,
  stdenvNoCC,
  bun,
  cacert,
  inputs,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "pi-web-access";
  version = inputs.pi-web-access.shortRev;

  src = inputs.pi-web-access;

  nativeBuildInputs = [ bun cacert ];

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-sxb+eZys2n5Yqm6olV5VHyOY8ReLL1Zrmy3ke0IsQuc=";

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
    description = "Web search, URL fetching, GitHub, PDF, YouTube, and video access for Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-web-access";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
