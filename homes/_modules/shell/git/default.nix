{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.shell.git;
  inherit (pkgs.stdenv) isDarwin;
in
{
  options.modules.shell.git = {
    enable = lib.mkEnableOption "git";
    username = lib.mkOption { type = lib.types.str; };
    email = lib.mkOption { type = lib.types.str; };
    config = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
    services = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
    includes = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs = {
        gh = {
          enable = true;
          extensions = [ pkgs.gh-copilot ];
        };
        git = {
          enable = true;

          userName = cfg.username;
          userEmail = cfg.email;

          extraConfig = lib.mkMerge [
            {
              core = {
                autocrlf = "input";
              };
              init = {
                defaultBranch = "main";
              };
              pull = {
                rebase = true;
              };
              rebase = {
                autoStash = true;
              };
            }
            cfg.config
          ];

          inherit (cfg) includes;

          aliases = {
            co = "checkout";
          };
          ignores = [
            # Mac OS X hidden files
            ".DS_Store"
            # Windows files
            "Thumbs.db"
            # asdf
            ".tool-versions"
            # mise
            ".mise.toml"
            # Sops
            ".decrypted~*"
            "*.decrypted.*"
            # Python virtualenvs
            ".venv"
          ];
        };

        lazygit = {
          enable = true;
          settings = {
            gui = {
              showIconns = true;
              nerdFontsVersion = 3;
              border = "rounded";
            };
            keybinding = {
              commits = {
                moveDownCommit = "<c-d>";
                moveUpCommit = "<c-u>";
              };
              universal = {
                scrollDownMain-alt2 = "<disabled>";
                scrollUpMain-alt2 = "<disabled>";
              };
            };
            inherit (cfg) services;
          };
        };
        fish = {
          shellAbbrs = {
            gg = "lazygit";
          };
        };
      };
      home.packages = [
        pkgs.git-filter-repo
        pkgs.tig
      ];

    })
    (lib.mkIf (cfg.enable && isDarwin) {
      programs.git = {
        extraConfig = {
          credential = {
            helper = "osxkeychain";
          };
        };
      };
    })
  ];
}
