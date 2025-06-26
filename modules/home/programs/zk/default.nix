{
  config,
  lib,
  pkgs,
  namespace,
  inputs,
  ...
}:

with lib;
let
  cfg = config.${namespace}.programs.zk;
  nixvim = inputs.editor.packages.${pkgs.system}.default;
in
{
  options.${namespace}.programs.zk = {
    enable = mkEnableOption "zk";
    default_directory = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The directory where zk stores its notes.
        If null, no directory will be specified and zk will use its default location.
      '';
    };
    author = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The author name to be used in the notes.
      '';
    };
  };
  
  config = mkIf cfg.enable {
    home.sessionVariables = mkIf (cfg.default_directory != null) {
      ZK_NOTEBOOK_DIR = cfg.default_directory;
    };
    home.file."${config.xdg.configHome}/zk/templates/" = {
      source = ./templates;
      recursive = true;
    };
    programs = {
      zk = {
        enable = true;
        settings = {
          note = {
            language = "en";
            defaultTitle = "Untitled";
            filename = "{{id}}";
            extension = "md";
            template = "default.md";
            idCharset = "alphanum";
            idLength = 4;
            idCase = "lower";
          };
          extra = {
            author = mkIf (cfg.author != null) cfg.author;
          };
          group = {
            daily = {
              paths = [ "daily" ];
              note = {
                filename = "{{format-date now 'daily/%Y-%m-%d'}}";
                template = "daily.md";
              };
            };
          };
          format = {
            markdown = {
              link-format = "markdown";
              hashtags = true;
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
            daily = "zk new --group daily";
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