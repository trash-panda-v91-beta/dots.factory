{
  lib,
  stdenvNoCC,
  fetchzip,
  nodejs_24,
  makeWrapper,
  ...
}:
let
  version = "1.10.0";
  platform =
    {
      aarch64-darwin = "darwin-arm64";
      x86_64-darwin = "darwin-x64";
      aarch64-linux = "linux-arm64";
      x86_64-linux = "linux-x64";
    }
    .${stdenvNoCC.hostPlatform.system} or (throw "unsupported system: ${stdenvNoCC.hostPlatform.system}");
  hashes = {
    aarch64-darwin = "sha256-T0VYKZCMmqkMW7qf/t8Znzwj4n188hOJn3n7ACFitMo=";
    x86_64-darwin = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # ponytail: unfilled - add when needed
    aarch64-linux = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # ponytail: unfilled - add when needed
    x86_64-linux = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # ponytail: unfilled - add when needed
  };
in
stdenvNoCC.mkDerivation {
  pname = "cfn-lsp";
  inherit version;

  src = fetchzip {
    url = "https://github.com/aws-cloudformation/cloudformation-languageserver/releases/download/v${version}/cloudformation-languageserver-${version}-${platform}-node22.zip";
    hash = hashes.${stdenvNoCC.hostPlatform.system};
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin
    cp -r $src/. $out/lib/
    makeWrapper ${nodejs_24}/bin/node $out/bin/cfn-lsp-server \
      --add-flags "$out/lib/cfn-lsp-server-standalone.js" \
      --add-flags "--stdio"
    runHook postInstall
  '';

  meta = {
    description = "AWS CloudFormation Language Server";
    homepage = "https://github.com/aws-cloudformation/cloudformation-languageserver";
    license = lib.licenses.asl20;
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    mainProgram = "cfn-lsp-server";
  };
}
