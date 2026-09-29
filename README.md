# Noctaliaa

My personal, opinionated fork of [Noctalia](https://github.com/noctalia-dev/noctalia-shell) v4.

Upstream moved on to v5 and v4 is archived. I liked v4, so I kept it alive and bent it to fit my own setup. This fork doesn't follow upstream anymore; things get added, changed or ripped out whenever that makes my desktop better.

It's a Quickshell (QML) desktop shell for Wayland: bar, panels, launcher, notifications, lock screen, OSD, dock, desktop widgets and wallpaper-based theming.

> [!NOTE]
> This is built for my machines first. You're welcome to use it or take pieces of it, but expect sharp opinions, breaking changes and no support promises.

## What's different from Noctalia v4

- **Settings open in their own window** instead of a panel attached to the bar.
- **Wallpapers are left to the system.** The shell doesn't draw or manage wallpapers; use whatever wallpaper tool you like. Colors can still be generated from your wallpaper.
- **Native AI usage widget** for Claude, Codex, Copilot, Gemini, OpenRouter and OpenCode Zen (previously a plugin).
- **Container outline controls**: thickness, color (from the current scheme), brightness and opacity.
- **Per-host settings** in `~/.config/noctaliaa/settings/<hostname>.json`, so one dotfiles repo can drive several machines.
- **Monochrome tray icons** that follow the accent color.
- **Theme refresh over IPC**: `qs -c noctaliaa ipc call colorScheme refresh`.
- Everything is renamed to `noctaliaa` so it can sit next to an upstream install (config name, `~/.config/noctaliaa`, `~/.cache/noctaliaa`, `NOCTALIAA_*` env vars).

## Requirements

- A Wayland compositor. Hyprland is what I use daily; Niri, Sway, Scroll, Labwc and MangoWC support comes from upstream and may or may not still work.
- Quickshell: [noctalia-qs](https://github.com/noctalia-dev/noctalia-qs)
- Python 3 (theming scripts and tests)

## Install

```sh
git clone https://github.com/luniiya/noctaliaa
cd noctaliaa
./install.sh
```

`install.sh` symlinks `~/.config/quickshell/noctaliaa` to the checkout and (re)starts the shell. Use `--copy` to copy instead of symlinking and `--no-restart` to skip the restart.

Start it from your compositor, e.g. in Hyprland:

```
exec-once = qs -c noctaliaa
```

Useful commands:

```sh
qs -c noctaliaa log                 # show the log
qs -c noctaliaa kill                # stop the shell
qs -c noctaliaa ipc call <target> <function>
```

## Development

```sh
Scripts/dev/run-tests.sh            # QML unit tests + repo consistency checks
```

Logic lives in plain JS under `Helpers/` so it can be unit tested headless; see `CLAUDE.md` for the conventions and the checklist for adding settings.

## Credits

Noctaliaa exists because of [Noctalia](https://github.com/noctalia-dev/noctalia-shell) and everyone who built it. All the good foundations are theirs. See [CREDITS.md](CREDITS.md) for the projects and people behind it.

Licensed under the MIT License, see [LICENSE](LICENSE).
