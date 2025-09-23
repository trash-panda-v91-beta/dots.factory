{
  cpio,
  xar,
  lib,
  stdenv,
  fetchFromGitHub,
  common-updater-scripts,
  writeShellScript,
  curl,
  jq,
  driver-version ? null,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "karabiner-dk";
  sourceVersion = "6.2.0";
  version = lib.defaultTo finalAttrs.sourceVersion driver-version;

  src = fetchFromGitHub {
    owner = "pqrs-org";
    repo = "Karabiner-DriverKit-VirtualHIDDevice";
    tag = "v${finalAttrs.sourceVersion}";
    hash = "sha256-Gw40F9gB+9sDg8swiOCfpCbc1gNHR0NbISOEJmpkWz8=";
  };

  nativeBuildInputs = [
    cpio
    xar
  ];

  unpackPhase = ''
    runHook preUnpack
    xar -xf $src/dist/Karabiner-DriverKit-VirtualHIDDevice-${finalAttrs.version}.pkg
    zcat Payload | cpio -i
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -R ./Applications ./Library "$out"
    find "$out" -name '._embedded.provisionprofile' | xargs rm
    runHook postInstall
  '';
  dontFixup = true;

  passthru.updateScript = writeShellScript "karabiner-dk" ''
    NEW_VERSION=$(${lib.getExe curl} --silent https://api.github.com/repos/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/latest | ${lib.getExe jq} '.tag_name | ltrimstr("v")' --raw-output)
    ${lib.getExe' common-updater-scripts "update-source-version"} "karabiner-dk" "$NEW_VERSION" --ignore-same-version --version-key="sourceVersion";
  '';

  meta = {
    changelog = "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/tag/${finalAttrs.src.tag}";
    description = "Virtual keyboard and virtual mouse using DriverKit on macOS";
    homepage = "https://karabiner-elements.pqrs.org/";
    maintainers = with lib.maintainers; [ auscyber ];
    license = lib.licenses.unlicense;
    platforms = lib.platforms.darwin;
  };
})
