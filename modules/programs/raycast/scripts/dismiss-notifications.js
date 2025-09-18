#!/usr/bin/env osascript

// @raycast.schemaVersion 1
// @raycast.title Dismiss notification
// @raycast.mode inline
// @raycast.packageName Raycast Scripts
// @raycast.icon 🔔
// @raycast.currentDirectoryPath ~
// @raycast.needsConfirmation false
// Documentation:
// @raycast.description Dismiss notification

(() => {
  const alertAndBannerSet = [
    "AXNotificationCenterAlert",
    "AXNotificationCenterBanner",
  ];
  const closeActionSet = ["Close", "Clear All", "Zavři!"];

  function getIndexOfItem(anItem, aList) {
    const index = aList.indexOf(anItem);
    if (index === -1) {
      throw new Error(`Item '$${anItem}' not found in list.`);
    }
    return index + 1;
  }

  function closeNotifications() {
    const systemEvents = Application("System Events");
    systemEvents.includeStandardAdditions = true;

    let mainGroup;
    try {
      mainGroup =
        // biome-ignore lint/complexity/useLiteralKeys: Not supported for apple script
        systemEvents.applicationProcesses["NotificationCenter"].windows[0]
          .groups[0].groups[0].scrollAreas[0].groups[0];
    } catch (error) {
      systemEvents.displayNotification(error.message, {
        withTitle: `Error $${error.number}`,
        soundName: "Frog",
      });
      return;
    }

    const headings = mainGroup
      .uiElements()
      .filter((el) => el.role() === "AXHeading");
    const headingsCount = headings.length;

    for (let i = 0; i < headingsCount; i++) {
      const roles = mainGroup.uiElements().map((el) => el.role());
      const headingIndex = getIndexOfItem("AXHeading", roles);
      const closeButtonIndex = headingIndex + 1;

      mainGroup.uiElements[closeButtonIndex - 1].click();
      delay(0.4);
    }

    try {
      const groups = mainGroup.groups();
      if (groups.length === 0) {
        if (alertAndBannerSet.includes(mainGroup.subrole())) {
          const actions = mainGroup.actions();
          actions.forEach((action) => {
            if (closeActionSet.includes(action.description())) {
              action.perform();
            }
          });
        }
        return;
      }

      groups.forEach((group) => {
        const actions = group.actions();
        actions.forEach((action) => {
          if (closeActionSet.includes(action.description())) {
            action.perform();
          }
        });
      });
    } catch (_error) {
      if (alertAndBannerSet.includes(mainGroup.subrole())) {
        const actions = mainGroup.actions();
        actions.forEach((action) => {
          if (closeActionSet.includes(action.description())) {
            action.perform();
          }
        });
      }
    }
  }

  closeNotifications();
})();
