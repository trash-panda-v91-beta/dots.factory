{
  delib,
  ...
}:
delib.module {
  name = "ai.skills.delivery-and-infra";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    xdg.configFile."opencode/skills/delivery-and-infra/SKILL.md".source = ./SKILL.md;
    programs.claude-code.skills.delivery-and-infra = ./SKILL.md;
  };
}
