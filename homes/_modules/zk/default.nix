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
    home.file."/brain/.zk/templates/daily.md".text = ''
      ---
      created: {{format-date now '%Y-%m-%d'}}
      tags:
        - daily
      ---

      # {{format-date now '%Y-%m-%d'}}

      ## Tasks

      ## Notes

      ## Navigation
      [ Yesterday ](/journal/daily/{{format-date (date "yesterday") '%Y/%Y-%m-%d'}}) <-> [ Tomorrow ](/journal/daily/{{format-date (date "tomorrow") '%Y/%Y-%m-%d'}})
    '';
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
            daily = {
              paths = [ "journal/daily" ];
              note = {
                filename = "{{format-date now 'journal/daily/%Y-%m-%d'}}";
                template = "daily.md";
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
            daily = "zk new --no-input \"$ZK_NOTEBOOK_DIR/journal/daily\"";
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
