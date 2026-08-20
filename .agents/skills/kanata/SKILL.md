---
name: kanata
description: Manage kanata on macOS - granting TCC permissions, restarting the daemon, diagnosing why shortcuts stopped working, and what to do after a kanata version bump. Use when kanata shortcuts stop working, when asked how to approve kanata in System Settings, after a Renovate update, or when the kanata daemon is running but not intercepting keys.
---

# kanata

Kanata runs as a root LaunchDaemon and needs two macOS TCC permissions:
- **Input Monitoring** (`kTCCServiceListenEvent`) - to read raw keyboard events
- **Accessibility** (`kTCCServiceAccessibility`) - to intercept and remap them

The approved binary is `/usr/local/bin/kanata` (a stable copy written by
`postActivation`). This path never changes between builds, so TCC approval
survives Renovate version bumps.

## Granting permissions

Do this once on a fresh machine, or if shortcuts stop working after a reinstall.

1. **System Settings > Privacy & Security > Input Monitoring**
   - Remove any stale `/nix/store/...` kanata entry
   - Click `+`, press `Cmd+Shift+G`, type `/usr/local/bin`, select `kanata`

2. **System Settings > Privacy & Security > Accessibility**
   - Same steps - remove stale entry, add `/usr/local/bin/kanata`

3. Restart the daemon:
   ```bash
   restart-kanata
   ```

## Checking current TCC state

```bash
sudo sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" \
  "SELECT service, client, auth_value FROM access WHERE client LIKE '%kanata%';"
```

`auth_value = 2` means approved. Both `kTCCServiceListenEvent` and
`kTCCServiceAccessibility` must show `/usr/local/bin/kanata` with value 2.

## Diagnosing a broken kanata

```bash
# Is the daemon running?
launchctl list | grep kanata

# What is it saying?
kanata-logs
```

Common states:

| Log says | Cause | Fix |
|---|---|---|
| `needs macOS Input Monitoring permission` | Input Monitoring not granted or stale entry | Re-grant in System Settings |
| `needs macOS Accessibility permission` | Accessibility not granted or stale entry | Re-grant in System Settings |
| `IOHIDDeviceOpen error: not permitted` | Accessibility stale (old store path) | Remove old entry, add `/usr/local/bin/kanata` |
| `virtual_hid_keyboard_ready true` loop, no errors | Running fine | Shortcuts work |
| nothing in logs, not in `launchctl list` | Daemon not loaded | `sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.kanata-internal.plist` |

## After a Renovate bump

Nothing to do. `mise run switch` copies the new binary to `/usr/local/bin/kanata`
(same path). The plist is unchanged so launchd does not restart the daemon.
TCC approval stays valid. Shortcuts keep working.

## Useful aliases

```bash
restart-kanata   # sudo launchctl kickstart -k system/org.nixos.kanata-internal
kanata-logs      # tail -f /var/log/kanata-internal.err.log /var/log/kanata-internal.out.log
```
