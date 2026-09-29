.pragma library

// Per-host settings file resolution. Kept free of QML/Quickshell dependencies
// so it can be unit tested (see Tests/tst_settingspaths.qml).
//
// Layout:
//   <configDir>/settings/<hostname>.json   per-host settings (default)
//   <configDir>/settings.json              legacy single file, used once to seed a new host

var fallbackHostName = "default";

// Turn raw hostname output into a safe file name
function sanitizeHostName(raw) {
  var name = String(raw === undefined || raw === null ? "" : raw).split("\n")[0].trim();
  // Keep the usual hostname characters, replace anything that could escape the directory
  name = name.replace(/[^A-Za-z0-9._-]/g, "_").replace(/^\.+/, "");
  return name.length > 0 ? name : fallbackHostName;
}

function ensureTrailingSlash(dir) {
  dir = String(dir || "");
  return dir.length > 0 && dir[dir.length - 1] !== "/" ? dir + "/" : dir;
}

function settingsDir(configDir) {
  return ensureTrailingSlash(configDir) + "settings/";
}

function legacySettingsFile(configDir) {
  return ensureTrailingSlash(configDir) + "settings.json";
}

function hostSettingsFile(configDir, hostName) {
  return settingsDir(configDir) + sanitizeHostName(hostName) + ".json";
}

// An explicit NOCTALIA_SETTINGS_FILE always wins over the per-host file
function resolveSettingsFile(envOverride, configDir, hostName) {
  if (envOverride && String(envOverride).length > 0)
    return String(envOverride);
  return hostSettingsFile(configDir, hostName);
}

function shellQuote(value) {
  return "'" + String(value).replace(/'/g, "'\\''") + "'";
}

// Shell script that creates the directories and, when the target settings file
// doesn't exist yet, seeds it from the legacy settings.json (copied, never moved).
// Pass an empty seedFrom to skip seeding.
function prepareScript(dirs, target, seedFrom) {
  var parts = ["mkdir -p " + dirs.map(shellQuote).join(" ")];
  if (seedFrom && target && seedFrom !== target) {
    var t = shellQuote(target);
    var s = shellQuote(seedFrom);
    parts.push("if [ ! -e " + t + " ] && [ -f " + s + " ]; then cp " + s + " " + t + "; fi");
  }
  return parts.join(" && ");
}
