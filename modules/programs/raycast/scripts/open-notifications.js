#!/usr/bin/env osascript

// @raycast.schemaVersion 1
// @raycast.title Open notification
// @raycast.mode inline
// @raycast.packageName Raycast Scripts
// @raycast.icon 🔔
// @raycast.currentDirectoryPath ~
// @raycast.needsConfirmation false
// Documentation:
// @raycast.description Open notification

const showActionSet = ["Show"];
const alertAndBannerSet = [
  "AXNotificationCenterAlert",
  "AXNotificationCenterBanner",
];

(() => {
  const systemEvents = Application("System Events");
  try {
    const notificationCenter =
      systemEvents.processes.byName("NotificationCenter");
    const mainGroup =
      notificationCenter.windows[0].groups[0].groups[0].scrollAreas[0]
        .groups[0];
    const groups = mainGroup.groups.whose({
      subrole: "AXNotificationCenterAlert",
    });

    let targetGroup;
    if (groups.length === 0) {
      if (alertAndBannerSet.includes(mainGroup.subrole())) {
        targetGroup = mainGroup;
      } else {
        return;
      }
    } else {
      targetGroup = groups[0];
    }

    const actions = targetGroup.actions();
    let showActionExists = false;

    for (const action of actions) {
      if (showActionSet.includes(action.description())) {
        action.perform();
        showActionExists = true;
        break;
      }
    }

    if (!showActionExists) {
      targetGroup.actions.byName("AXPress").perform();
    }
  } catch (error) {
    const notification = Application.currentApplication();
    notification.includeStandardAdditions = true;
    notification.displayNotification(error.message, {
      withTitle: `Error $${error.number}`,
    });
  }
})();
