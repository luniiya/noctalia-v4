# Noctalia v4 – agent notes

Quickshell (QML) desktop shell. Entry point `shell.qml`; singletons in `Commons/` and `Services/`, UI in `Modules/` and `Widgets/`, pure JS helpers in `Helpers/`.

## Testing (required)

Every change must come with unit tests, and the full suite must pass before you report work as done.

```sh
Scripts/dev/run-tests.sh          # QML unit tests + Python repo checks
Scripts/dev/run-tests.sh -silent  # quieter; this is what the pre-commit hook runs
```

- **QML/JS unit tests** live in `Tests/tst_*.qml` and run headless with Qt Quick Test (`qmltestrunner`). Each file is a `TestCase` with `test_*` functions; use `_data()` functions for table-driven cases.
- **Repository consistency tests** live in `Tests/python/` (stdlib `unittest`): translation keys used in QML exist in `en.json`, the settings search index is up to date, settings options match the UI.
- **Make logic testable.** QML files that import `qs.*` singletons or Quickshell types can't be loaded by `qmltestrunner`. Put non-trivial logic (geometry, parsing, state decisions) in a `.pragma library` JS file under `Helpers/` (see `Helpers/NotchGeometry.js`), call it from QML, and test the JS directly.
- When a test exposes a bug in existing code, fix it and mention it in your summary. Don't weaken the test.
- Add regression tests for bugs you fix.

## Live testing

`./install.sh` symlinks `~/.config/quickshell/noctalia-shell` to this checkout and restarts the shell (`--no-restart`, `--copy` available). Check the log with `qs -c noctalia-shell log`. Never `pkill -f "qs -c noctalia-shell"`: it matches the invoking shell too. Use `qs -c noctalia-shell kill`.

## Conventions

- User settings are per host: `~/.config/noctalia/settings/<hostname>.json` (path logic in `Helpers/SettingsPaths.js`). A new host is seeded once from the legacy `settings.json`; `NOCTALIA_SETTINGS_FILE` overrides the path.
- Settings live in `Commons/Settings.qml` (`JsonAdapter`); every new setting needs a default there. Breaking changes to settings need a migration in `Commons/Migrations/` and a bump of `settingsVersion`.

## Checklist: adding or changing a setting

Do **all** of these, every time. Missing one breaks the setting's reset button or search entry without any visible error.

1. Add or change the default in `Commons/Settings.qml`.
2. Add or change **the same value** in `Assets/settings-default.json`. It backs `Settings.getDefaultValue()`, which every reset button uses.
3. Add the UI control in `Modules/Panels/Settings/Tabs/...` with `defaultValue: Settings.getDefaultValue("section.key")`.
4. Add the label and description keys to `Assets/Translations/en.json`.
5. Run `python3 Scripts/dev/build-settings-search-index.py`.
6. If existing users need their saved value changed or renamed, add a migration. Changing a default only affects new installs and people who never saved that key.
7. Put any logic behind the setting in a `Helpers/*.js` module and add unit tests for it.
8. Run `Scripts/dev/run-tests.sh`. `Tests/python/test_settings_defaults.py` fails if steps 1 and 2 disagree, and `test_repo_consistency.py` catches missing translations and a stale search index.
- User-facing strings go through `I18n.tr("…")` with keys added to `Assets/Translations/en.json` only (other languages are synced separately).
- After changing settings UI, run `python3 Scripts/dev/build-settings-search-index.py`.
- `Scripts/dev/qmlfmt.sh` formats every QML file. If your local `qmlformat` version reformats files you didn't touch, revert those files and keep the diff limited to your change.
- Match surrounding code: 2-space indent in QML/JS, comment density and naming of neighbouring code.
