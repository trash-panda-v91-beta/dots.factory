{
  lib,
  writeShellScriptBin,
  inputs,
  _1password-cli,
  envVars ? { },
}:
let
  opencode = inputs.opencode.packages.aarch64-darwin.default;
  opencodeExe = lib.getExe opencode;
  opExe = lib.getExe _1password-cli;
in
# Create wrapper that injects 1Password secrets at runtime
if envVars == { } then
  opencode
else
  let
    # Convert env vars to op run --env-file format
    envFileContent = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: "${name}=${value}") envVars
    );
    envFile = builtins.toFile "opencode-env" envFileContent;
  in
  writeShellScriptBin "opencode-wrapped" ''
    exec ${opExe} run --no-masking --env-file=${envFile} -- ${opencodeExe} "$@"
  ''
