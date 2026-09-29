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

- Settings live in `Commons/Settings.qml` (`JsonAdapter`); every new setting needs a default there. Breaking changes to settings need a migration in `Commons/Migrations/` and a bump of `settingsVersion`.
- User-facing strings go through `I18n.tr("…")` with keys added to `Assets/Translations/en.json` only (other languages are synced separately).
- After changing settings UI, run `python3 Scripts/dev/build-settings-search-index.py`.
- `Scripts/dev/qmlfmt.sh` formats every QML file. If your local `qmlformat` version reformats files you didn't touch, revert those files and keep the diff limited to your change.
- Match surrounding code: 2-space indent in QML/JS, comment density and naming of neighbouring code.
