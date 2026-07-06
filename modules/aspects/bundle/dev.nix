# Dev bundle - the coding capability stack
{ __findFile, ... }:
{
  dots.bundle._.dev = {
    description = "Coding stack: terminal, editor, git, dev tooling, AI, language runtimes";
    includes = [
      <dots/tool/terminal>
      <dots/tool/nixvim>
      <dots/tool/git>
      <dots/tool/hunk>
      <dots/tool/dev-tools>
      <dots/tool/ai>
      <dots/tool/runtimes>
    ];
  };
}
