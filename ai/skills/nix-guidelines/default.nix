{
  delib,
  ...
}:
delib.module {
  name = "ai.skills.nix-guidelines";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    xdg.configFile."opencode/skills/nix-guidelines/SKILL.md".source = ./SKILL.md;
    programs.claude-code.skills.nix-guidelines = ./SKILL.md;
  };
}
