#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Rebuild dots
# @raycast.mode compact
# @raycast.packageName Raycast Scripts
# @raycast.icon ⚫
# @raycast.currentDirectoryPath ~
# @raycast.needsConfirmation false
# Documentation:
# @raycast.description Run NixOS rebuild command

/run/current-system/sw/bin/darwin-rebuild switch --flake "git+ssh://git@github.com/$USER/dot.factory/#$HOSTNAME"
