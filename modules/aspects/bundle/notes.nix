# Notes bundle - knowledge management capability
{ __findFile, ... }:
{
  dots.bundle._.notes = {
    description = "Knowledge management capability (Obsidian + future tools)";
    includes = [ <dots/tool/obsidian> ];
  };
}
