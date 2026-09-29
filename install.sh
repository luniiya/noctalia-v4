#!/usr/bin/env bash
# Install this Noctalia checkout as the user's noctalia-shell config.
#
# Usage: ./install.sh [--copy] [--no-restart]
#   default       symlink ~/.config/quickshell/noctalia-shell -> this repo (edits go live on restart)
#   --copy        copy the files instead of symlinking
#   --no-restart  don't restart the running shell afterwards
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/noctalia-shell"
MODE="link"
RESTART=1

for arg in "$@"; do
  case "$arg" in
  --copy) MODE="copy" ;;
  --no-restart) RESTART=0 ;;
  -h | --help)
    sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "Unknown option: $arg" >&2
    exit 1
    ;;
  esac
done

if ! command -v qs >/dev/null 2>&1; then
  echo "Quickshell ('qs') not found. Install noctalia-qs first (e.g. 'paru -S noctalia-qs')." >&2
  exit 1
fi

if [ -e /etc/xdg/quickshell/noctalia-shell ]; then
  echo "Note: a system copy exists at /etc/xdg/quickshell/noctalia-shell."
  echo "      $TARGET takes precedence, but you can remove the package with: sudo pacman -Rns noctalia-shell"
fi

mkdir -p "$(dirname "$TARGET")"

# Back up whatever is there, unless it's already our symlink
if [ -L "$TARGET" ] && [ "$(readlink -f "$TARGET")" = "$REPO_DIR" ] && [ "$MODE" = "link" ]; then
  echo "Already linked: $TARGET -> $REPO_DIR"
elif [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
  BACKUP="$TARGET.bak-$(date +%Y%m%d-%H%M%S)"
  echo "Backing up existing $TARGET -> $BACKUP"
  mv "$TARGET" "$BACKUP"
fi

if [ ! -e "$TARGET" ]; then
  if [ "$MODE" = "link" ]; then
    ln -s "$REPO_DIR" "$TARGET"
    echo "Linked $TARGET -> $REPO_DIR"
  else
    mkdir -p "$TARGET"
    tar -C "$REPO_DIR" --exclude=.git -cf - . | tar -C "$TARGET" -xf -
    echo "Copied $REPO_DIR -> $TARGET"
  fi
fi

if [ "$RESTART" -eq 1 ] && [ -n "${WAYLAND_DISPLAY:-}" ]; then
  echo "Restarting noctalia-shell..."
  qs -c noctalia-shell kill >/dev/null 2>&1 || true
  sleep 0.5
  setsid -f qs -c noctalia-shell >/dev/null 2>&1
fi

echo "Done. Launch manually with: qs -c noctalia-shell"
