{
  delib,
  lib,
  pkgs,
  config,
  ...
}:

delib.module {
  name = "libraryLinking";

  options.libraryLinking = with delib.options; {
    enable = boolOption true;
    subdirs = listOfOption str [
      "Application Support"
      "Audio"
      "Audio/Plugins"
    ];
  };

  darwin.ifEnabled =
    { cfg, ... }:
    {
      # Override the system.build.applications to include /Library paths
      system.build.applications = lib.mkForce (
        pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = [
            "/Applications"
            "/Library"
          ];
        }
      );

      # Add custom activation script for library linking
      # Run it in the applications script so it happens before launchd
      system.activationScripts.applications.text = lib.mkAfter ''
        echo "setting up library paths for apps..." >&2

        if [ -d "${config.system.build.applications}/Library" ] || [ -e "${config.system.build.applications}/Library" ]; then
          rsyncFlags=(
            --checksum
            --archive
            --copy-unsafe-links
            --chmod=-w
          )
          
          copy_sub () {
            local subdir="$1"
            local targetFolder="/Library/$subdir"
            
            # Create target folder if it doesn't exist
            mkdir -p "$targetFolder"
            
            # delete folders that are just below target folder and in the source folder
            find "$targetFolder" -maxdepth 1 -type d -exec bash -c \
              'folderName=$(basename "$0"); \
               if [ -d "${config.system.build.applications}/Library/'"$subdir"'/$folderName" ] && [ "$folderName" != "$(basename '"$subdir"')" ]; then \
                 echo "  removing old $0" >&2; \
                 rm -rf "$0"; \
               fi \
              ' {} \;
            
            if [ -d "${config.system.build.applications}/Library/$subdir" ]; then
              echo "  copying library paths to $targetFolder" >&2
              ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" "${config.system.build.applications}/Library/$subdir/" "$targetFolder/"
            else
              echo "  no content found for $subdir (skipping)" >&2
            fi
          }
          
          ${lib.concatMapStringsSep "\n" (subdir: ''copy_sub "${subdir}"'') cfg.subdirs}
        else
          echo "  no Library directory in system-applications (skipping)" >&2
        fi
      '';
    };
}
