{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.obsidian";

  options.programs.obsidian = with delib; {
    enable = boolOption false;
    vaults = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              target = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Path to the vault relative to the user's HOME directory.";
              };
            };
          }
        )
      );
      default = { };
      description = "Obsidian vaults to configure, keyed by vault name.";
    };
  };

  myconfig.ifEnabled.unfreePackages.allow = [
    "obsidian"
  ];

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.obsidian = {

        # Enable Obsidian CLI (sets `cli: true` in obsidian.json)
        cli.enable = true;

        # Default settings applied to all vaults — follows stephango.com/vault conventions
        defaultSettings = {
          # Matches stephango's app.json exactly, plus vim mode
          app = {
            attachmentFolderPath = "Attachments";
            alwaysUpdateLinks = true;
            vimMode = true;
          };

          # Core plugins — matches stephango's core-plugins.json
          # Strings are coerced to { name = p; enable = true; settings = null; }
          # Plugin configs are written to .obsidian/<name>.json via settings = { ... }
          corePlugins = [
            "audio-recorder"
            "backlink"
            "bases"
            "bookmarks"
            "canvas"
            "command-palette"
            {
              name = "daily-notes";
              settings = {
                folder = "Daily";
                template = "Templates/Daily Note Template";
              };
            }
            "editor-status"
            "file-explorer"
            "file-recovery"
            "global-search"
            "graph"
            "markdown-importer"
            "note-composer"
            "outline"
            "page-preview"
            "random-note"
            "switcher"
            "tag-pane"
            {
              name = "templates";
              settings = {
                folder = "Templates";
              };
            }
            "workspaces"
            {
              name = "zk-prefixer";
              settings = {
                format = "YYYY-MM-DD HHmm";
                folder = "/";
                template = "Templates/Journal Template";
              };
            }
          ];

          # Minimal theme by @kepano
          themes = [ pkgs.local.obsidian-minimal-theme ];

          communityPlugins = [
            {
              pkg = pkgs.local.obsidian-tasknotes-plugin;
              # Task-per-note, stored in Tasks/ — follows stephango.com/vault folder conventions
              # zettel filename format keeps YYYY-MM-DD HHmm prefix, matching his unique note style
              settings = {
                tasksFolder = "Tasks";
                archiveFolder = "Tasks/Archive";
                taskTag = "task";
                taskIdentificationMethod = "tag";
                taskFilenameFormat = "zettel";
                storeTitleInFilename = true;
                moveArchivedTasks = true;
                autoCreateDefaultBasesFiles = true;
                enableBases = true;
                # Task body template — file lives in Templates/ alongside other vault templates
                # Variables: {{title}}, {{date}}, {{priority}}, {{status}}, {{contexts}}, {{projects}}
                taskCreationDefaults = {
                  useBodyTemplate = true;
                  bodyTemplate = "Templates/Task Template";
                };
                commandFileMapping = {
                  "open-calendar-view" = "Tasks/Views/mini-calendar-default.base";
                  "open-kanban-view" = "Tasks/Views/kanban-default.base";
                  "open-tasks-view" = "Tasks/Views/tasks-default.base";
                  "open-advanced-calendar-view" = "Tasks/Views/calendar-default.base";
                  "open-agenda-view" = "Tasks/Views/agenda-default.base";
                  "relationships" = "Tasks/Views/relationships.base";
                };
              };
            }
            pkgs.local.obsidian-minimal-settings-plugin
          ];

          # Property type definitions — matches stephango's types.json
          extraFiles."types" = {
            target = "types.json";
            text = builtins.toJSON {
              types = {
                aliases = "aliases";
                cssclasses = "multitext";
                tags = "tags";
                categories = "multitext";
                created = "date";
                genre = "multitext";
                director = "multitext";
                last = "date";
                date = "date";
                topics = "multitext";
                rating = "number";
                year = "number";
                coordinates = "multitext";
                model = "text";
                isbn13 = "number";
                isbn = "number";
                ingredients = "multitext";
                imdbId = "text";
                system = "text";
                sqft = "number";
                speaker = "multitext";
                season = "number";
                series = "multitext";
                source = "text";
                status = "multitext";
                twitter = "text";
                trade = "text";
                purchased = "date";
                producer = "multitext";
                process = "text";
                phone = "text";
                role = "text";
                birthday = "date";
                guests = "multitext";
                cuisine = "multitext";
                conference = "text";
                end = "date";
                address = "text";
                start = "date";
                shares = "number";
                variety = "text";
                price = "number";
                author = "multitext";
                published = "date";
                where = "multitext";
                loc = "multitext";
                "monthly-uses" = "number";
                runtime = "number";
                pages = "number";
                acquired = "date";
              };
            };
          };
        };

        vaults = cfg.vaults;
      };
    };
}
