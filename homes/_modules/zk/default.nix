{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.zk;
  nixvim = inputs.editor.packages.${pkgs.system}.default;
  brain = config.home.homeDirectory + "/brain";
in
{
  options.modules.zk = {
    enable = lib.mkEnableOption "zk";
  };
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      ZK_NOTEBOOK_DIR = brain;
    };
    programs = {
      zk = {
        enable = true;
        settings = {
          notebook = {
            dir = brain;
          };
          note = {
            language = "en";
            defaultTitle = "Untitled";
            filename = "{{id}}-{{slug title}}";
            extension = "md";
            template = "default.md";
            idCharset = "alphanum";
            idLength = 4;
            idCase = "lower";
          };
          extra = {
            author = "trash-panda";
          };
          group = {
            journal = {
              paths = [
                "journal/weekly"
                "journal/daily"
              ];
              note = {
                filename = "{{format-date now}}";
              };
            };
          };
          format = {
            markdown = {
              hashtags = true;
              colonTags = true;
            };
          };
          tool = {
            editor = "${nixvim}/bin/nvim";
            shell = "${pkgs.fish}/bin/fish";
            pager = "less -FIRX";
            fzfPreview = "${pkgs.bat}/bin/bat -p --color always {-1}";
          };
          filter = {
            recents = "--sort created- --created-after 'last two weeks'";
          };
          alias = {
            edlast = "zk edit --limit 1 --sort modified- $@";
            recent = "zk edit --sort created- --created-after 'last two weeks' --interactive";
            lucky = "zk list --quiet --format full --sort random --limit 1";
          };
          lsp = {
            diagnostics = {
              wikiTitle = "hint";
              deadLink = "error";
            };
          };
        };
      };
    };
  };
}
