{ den, lib, ... }:
{
  dots.obsidian =
    { user, ... }:
    {
      description = "Obsidian knowledge management with tasknotes, bases, minimal theme";
      includes = [ (den._.unfree [ "obsidian" ]) ];

      homeManager =
        { pkgs, ... }:
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
                  name = "sync";
                  settings.syncPluginSettings = false;
                }
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
                {
                  pkg = pkgs.local.obsidian-minimal-settings-plugin;
                  settings = {
                    # Dark background: black variant matches cyberdream's dark bg
                    darkStyle = "minimal-dark-black";
                    # Accent color applied to active states and headings
                    colorfulHeadings = true;
                    colorfulActiveStates = true;
                    # Line numbers in code blocks
                    lineNumbers = true;
                    # Disable settings that conflict with Nix-owned appearance.json
                    # (darkScheme/lightScheme left at default — accent is set via appearance.accentColor)
                  };
                }
              ];
            };
          };
        };
    };
}
