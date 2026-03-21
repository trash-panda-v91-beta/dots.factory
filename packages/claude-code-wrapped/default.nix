{
  lib,
  pkgs,
  writeShellScriptBin,
  _1password-cli,
  envVars ? { },
}:
let
  claudeCode = pkgs.claude-code;
  claudeCodeExe = lib.getExe claudeCode;
  opExe = lib.getExe _1password-cli;
in
# Create wrapper that injects 1Password secrets at runtime
if envVars == { } then
  claudeCode
else
  let
    # Convert env vars to op run --env-file format
    envFileContent = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: "${name}=${value}") envVars
    );
    envFile = builtins.toFile "claude-code-env" envFileContent;
  in
  writeShellScriptBin "claude-code-wrapped" ''
    exec ${opExe} run --no-masking --env-file=${envFile} -- ${claudeCodeExe} "$@"
  ''
