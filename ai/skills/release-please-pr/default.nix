{
  delib,
  ...
}:
delib.module {
  name = "ai.skills.release-please-pr";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    xdg.configFile."opencode/skills/release-please-pr/SKILL.md".source = ./SKILL.md;
    programs.claude-code.skills.release-please-pr = ./SKILL.md;
  };
}
