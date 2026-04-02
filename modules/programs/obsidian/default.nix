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

        enable = true;
        cli.enable = true;

        defaultSettings = {
          app = {
            attachmentFolderPath = "Attachments";
            alwaysUpdateLinks = true;
            vimMode = true;
          };

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

          themes = [ pkgs.local.obsidian-minimal-theme ];

          communityPlugins = [
            {
              pkg = pkgs.local.obsidian-tasknotes-plugin;
              settings = {
                tasksFolder = "Tasks";
                archiveFolder = "Tasks/Archive";
                taskTag = "task";
                taskIdentificationMethod = "tag";
                taskFilenameFormat = "custom";
                customFilenameTemplate = "{{date}} {{hour}}{{minute}} {{title}}";
                storeTitleInFilename = false;
                moveArchivedTasks = true;
                autoCreateDefaultBasesFiles = true;
                enableBases = true;
                taskCreationDefaults = {
                  useBodyTemplate = true;
                  bodyTemplate = "Templates/Task Template";
                };
                commandFileMapping = {
                  "open-calendar-view" = "Templates/Bases/MiniCalendar.base";
                  "open-kanban-view" = "Templates/Bases/Kanban.base";
                  "open-tasks-view" = "Templates/Bases/Tasks.base";
                  "open-advanced-calendar-view" = "Templates/Bases/Calendar.base";
                  "open-agenda-view" = "Templates/Bases/Agenda.base";
                  "relationships" = "Templates/Bases/Relationships.base";
                };
                fieldMapping = {
                  dateCreated = "created";
                  dateModified = "modified";
                  completedDate = "completed";
                };
              };
            }
            pkgs.local.obsidian-minimal-settings-plugin
          ];

          extraFiles."types" = {
            target = "types.json";
            text = builtins.toJSON {
              types = {
                "monthly-uses" = "number";
                acquired = "date";
                address = "text";
                aliases = "aliases";
                author = "multitext";
                birthday = "date";
                categories = "multitext";
                conference = "text";
                coordinates = "multitext";
                created = "date";
                cssclasses = "multitext";
                cuisine = "multitext";
                date = "date";
                director = "multitext";
                end = "date";
                genre = "multitext";
                guests = "multitext";
                imdbId = "text";
                ingredients = "multitext";
                isbn = "number";
                isbn13 = "number";
                last = "date";
                loc = "multitext";
                model = "text";
                pages = "number";
                phone = "text";
                price = "number";
                process = "text";
                producer = "multitext";
                published = "date";
                purchased = "date";
                rating = "number";
                role = "text";
                runtime = "number";
                season = "number";
                series = "multitext";
                shares = "number";
                source = "text";
                speaker = "multitext";
                sqft = "number";
                start = "date";
                status = "multitext";
                system = "text";
                tags = "tags";
                topics = "multitext";
                trade = "text";
                twitter = "text";
                variety = "text";
                where = "multitext";
                year = "number";
              };
            };
          };
        };

        vaults = cfg.vaults;
      };
    };
}
