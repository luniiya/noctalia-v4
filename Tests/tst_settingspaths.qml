import QtQuick
import QtTest
import "../Helpers/SettingsPaths.js" as SettingsPaths

TestCase {
  name: "SettingsPaths"

  function test_sanitizeHostName_data() {
    return [
      { tag: "plain", raw: "cubeberry", expected: "cubeberry" },
      { tag: "trailing newline", raw: "cubeberry\n", expected: "cubeberry" },
      { tag: "surrounding spaces", raw: "  laptop  ", expected: "laptop" },
      { tag: "only first line", raw: "desk\nextra", expected: "desk" },
      { tag: "dashes and dots kept", raw: "my-pc.local", expected: "my-pc.local" },
      { tag: "case kept", raw: "MyPC", expected: "MyPC" },
      { tag: "slash replaced", raw: "a/b", expected: "a_b" },
      { tag: "path traversal", raw: "../etc", expected: "_etc" },
      { tag: "leading dots stripped", raw: "..hidden", expected: "hidden" },
      { tag: "spaces replaced", raw: "my pc", expected: "my_pc" },
      { tag: "quotes replaced", raw: "it's", expected: "it_s" },
      { tag: "empty", raw: "", expected: "default" },
      { tag: "whitespace only", raw: " \n", expected: "default" },
      { tag: "only dots", raw: "..", expected: "default" },
      { tag: "undefined", raw: undefined, expected: "default" },
      { tag: "null", raw: null, expected: "default" }
    ];
  }

  function test_sanitizeHostName(data) {
    compare(SettingsPaths.sanitizeHostName(data.raw), data.expected);
  }

  function test_ensureTrailingSlash() {
    compare(SettingsPaths.ensureTrailingSlash("/a/b"), "/a/b/");
    compare(SettingsPaths.ensureTrailingSlash("/a/b/"), "/a/b/");
    compare(SettingsPaths.ensureTrailingSlash(""), "");
  }

  function test_paths() {
    compare(SettingsPaths.settingsDir("/home/u/.config/noctaliaa/"), "/home/u/.config/noctaliaa/settings/");
    compare(SettingsPaths.settingsDir("/home/u/.config/noctaliaa"), "/home/u/.config/noctaliaa/settings/");
    compare(SettingsPaths.legacySettingsFile("/cfg/"), "/cfg/settings.json");
    compare(SettingsPaths.hostSettingsFile("/cfg/", "cubeberry\n"), "/cfg/settings/cubeberry.json");
    compare(SettingsPaths.hostSettingsFile("/cfg/", ""), "/cfg/settings/default.json");
  }

  function test_resolveSettingsFile() {
    compare(SettingsPaths.resolveSettingsFile("", "/cfg/", "laptop"), "/cfg/settings/laptop.json");
    compare(SettingsPaths.resolveSettingsFile(undefined, "/cfg/", "laptop"), "/cfg/settings/laptop.json");
    compare(SettingsPaths.resolveSettingsFile("/tmp/custom.json", "/cfg/", "laptop"), "/tmp/custom.json");
  }

  function test_resolveSettingsFile_differsPerHost() {
    verify(SettingsPaths.resolveSettingsFile("", "/cfg/", "desk") !== SettingsPaths.resolveSettingsFile("", "/cfg/", "laptop"));
  }

  function test_shellQuote() {
    compare(SettingsPaths.shellQuote("/a b/c"), "'/a b/c'");
    compare(SettingsPaths.shellQuote("it's"), "'it'\\''s'");
    compare(SettingsPaths.shellQuote("$(rm -rf ~)"), "'$(rm -rf ~)'");
  }

  function test_prepareScript_withSeed() {
    var script = SettingsPaths.prepareScript(["/cfg/", "/cache/", "/cfg/settings/"], "/cfg/settings/h.json", "/cfg/settings.json");
    compare(script, "mkdir -p '/cfg/' '/cache/' '/cfg/settings/' && if [ ! -e '/cfg/settings/h.json' ] && [ -f '/cfg/settings.json' ]; then cp '/cfg/settings.json' '/cfg/settings/h.json'; fi");
  }

  function test_prepareScript_withoutSeed() {
    compare(SettingsPaths.prepareScript(["/cfg/"], "/x.json", ""), "mkdir -p '/cfg/'");
    // Never copy a file onto itself
    compare(SettingsPaths.prepareScript(["/cfg/"], "/cfg/settings.json", "/cfg/settings.json"), "mkdir -p '/cfg/'");
  }
}
