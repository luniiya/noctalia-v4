pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.Power
import qs.Services.Theming
import qs.Services.UI

Singleton {
  id: root

  // Hook connections for automatic script execution
  Connections {
    target: Settings.data.colorSchemes
    function onDarkModeChanged() {
      executeDarkModeHook(Settings.data.colorSchemes.darkMode);
    }
  }

  Connections {
    target: TemplateProcessor
    function onColorsGenerated() {
      executeColorGenerationHook();
    }
  }

  // Track lock screen state for unlock hook
  property bool wasLocked: false

  Connections {
    target: PanelService
    function onLockScreenChanged() {
      if (PanelService.lockScreen) {
        lockScreenActiveConnection.target = PanelService.lockScreen;
      }
    }
  }

  Connections {
    id: lockScreenActiveConnection
    target: PanelService.lockScreen
    function onActiveChanged() {
      // Detect lock: was unlocked, now locked
      if (!wasLocked && PanelService.lockScreen.active) {
        executeLockHook();
      }
      // Detect unlock: was locked, now not locked
      if (wasLocked && !PanelService.lockScreen.active) {
        executeUnlockHook();
      }
      wasLocked = PanelService.lockScreen.active;
    }
  }

  // Track performance mode state for hooks
  property bool wasPerformanceModeEnabled: false

  Connections {
    target: PowerProfileService
    function onNoctaliaaPerformanceModeChanged() {
      const isEnabled = PowerProfileService.noctaliaaPerformanceMode;

      // Detect enabled: was disabled, now enabled
      if (!wasPerformanceModeEnabled && isEnabled) {
        executePerformanceModeEnabledHook();
      }
      // Detect disabled: was enabled, now disabled
      if (wasPerformanceModeEnabled && !isEnabled) {
        executePerformanceModeDisabledHook();
      }
      wasPerformanceModeEnabled = isEnabled;
    }
  }

  // Execute dark mode change hook
  function executeDarkModeHook(isDarkMode) {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.darkModeChange;
    if (!script || script === "") {
      return;
    }

    try {
      const command = script.replace(/\$1/g, isDarkMode ? "true" : "false");
      Quickshell.execDetached(["sh", "-lc", command]);
      Logger.d("HooksService", `Executed dark mode hook: ${command}`);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute dark mode hook: ${e}`);
    }
  }

  // Execute screen lock hook
  function executeLockHook() {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.screenLock;
    if (!script || script === "") {
      return;
    }

    try {
      // Pass "lock" as $1 via shell arguments so the script receives it
      Quickshell.execDetached(["sh", "-lc", script, "lock-hook", "lock"]);
      Logger.d("HooksService", `Executed screen lock hook: ${script}`);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute screen lock hook: ${e}`);
    }
  }

  // Execute screen unlock hook
  function executeUnlockHook() {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.screenUnlock;
    if (!script || script === "") {
      return;
    }

    try {
      // Pass "unlock" as $1 via shell arguments so the script receives it
      Quickshell.execDetached(["sh", "-lc", script, "unlock-hook", "unlock"]);
      Logger.d("HooksService", `Executed screen unlock hook: ${script}`);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute screen unlock hook: ${e}`);
    }
  }

  // Execute performance mode enabled hook
  function executePerformanceModeEnabledHook() {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.performanceModeEnabled;
    if (!script || script === "") {
      return;
    }

    try {
      Quickshell.execDetached(["sh", "-lc", script]);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute performance mode enabled hook: ${e}`);
    }
  }

  // Execute performance mode disabled hook
  function executePerformanceModeDisabledHook() {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.performanceModeDisabled;
    if (!script || script === "") {
      return;
    }

    try {
      Quickshell.execDetached(["sh", "-lc", script]);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute performance mode disabled hook: ${e}`);
    }
  }

  // Execute color generation hook
  function executeColorGenerationHook() {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.colorGeneration;
    if (!script || script === "") {
      return;
    }

    try {
      const theme = Settings.data.colorSchemes.darkMode ? "dark" : "light";
      const command = script.replace(/\$1/g, theme);
      Quickshell.execDetached(["sh", "-lc", command]);
      Logger.d("HooksService", `Executed color generation hook: ${command}`);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute color generation hook: ${e}`);
    }
  }

  // Blocking power hook infrastructure
  property var pendingPowerCallback: null

  Process {
    id: powerHookProcess
    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0) {
        Logger.w("HooksService", `Power hook failed with exit code ${exitCode}`);
      }

      if (pendingPowerCallback !== null) {
        const callback = pendingPowerCallback;
        pendingPowerCallback = null;
        callback();
      }
    }
  }

  function runPowerHook(script, callback) {
    pendingPowerCallback = callback;
    powerHookProcess.command = ["sh", "-lc", script];
    powerHookProcess.running = true;
  }

  function executeSessionHook(action, callback) {
    if (!Settings.data.hooks?.enabled) {
      callback();

      return;
    }

    const script = Settings.data.hooks?.session;
    if (!script) {
      callback();

      return;
    }

    Logger.i("HooksService", `Executing session hook for ${action}`);
    runPowerHook(`${script} ${action}`, callback);
  }

  // Execute startup hook
  function executeStartupHook() {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.startup;
    if (!script || script === "") {
      return;
    }

    try {
      Quickshell.execDetached(["sh", "-lc", script]);
      Logger.d("HooksService", `Executed startup hook: ${script}`);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute startup hook: ${e}`);
    }
  }

  // Initialize the service
  function init() {
    Logger.i("HooksService", "Service started");
    // Initialize lock screen state tracking
    Qt.callLater(() => {
                   if (PanelService.lockScreen) {
                     wasLocked = PanelService.lockScreen.active;
                     lockScreenActiveConnection.target = PanelService.lockScreen;
                   }
                   // Initialize performance mode state tracking
                   wasPerformanceModeEnabled = PowerProfileService.noctaliaaPerformanceMode;
                   // Execute startup hook
                   executeStartupHook();
                 });
  }
}
