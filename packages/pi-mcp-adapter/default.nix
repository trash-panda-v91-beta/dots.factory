{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  cacert,
  ...
}:
let
  rev = "a764c25609d8daf76e607bc99557621fc3ed8aa9";
  package = stdenvNoCC.mkDerivation {
    pname = "pi-mcp-adapter";
    version = "2.10.0";

    src = fetchFromGitHub {
      owner = "nicobailon";
      repo = "pi-mcp-adapter";
      inherit rev;
      hash = "sha256-MrorLzxbn3O81B47Nd0d0xnd0xhXgMdobnXgD0axldE=";
    };

    nativeBuildInputs = [ bun ];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-6AyYPEQxXA1BTeG0Mq6B98ql87USVsc3/le1sFvk3pI=";

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
  };
in
package
