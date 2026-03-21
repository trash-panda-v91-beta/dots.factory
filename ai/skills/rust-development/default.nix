{
  delib,
  ...
}:
delib.module {
  name = "ai.skills.rust-development";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    xdg.configFile."opencode/skills/rust-development/SKILL.md".source = ./SKILL.md;
    programs.claude-code.skills.rust-development = ./SKILL.md;
  };
}
