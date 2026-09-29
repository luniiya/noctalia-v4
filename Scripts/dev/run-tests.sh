#!/usr/bin/env -S bash
set -euo pipefail

# Test runner - QML unit tests (Qt Quick Test) then Python repository checks.
# Usage: Scripts/dev/run-tests.sh [extra qmltestrunner args, e.g. -functions or a test name]

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

RUNNER=""
for path in "/usr/lib64/qt6/bin/qmltestrunner" "/usr/lib/qt6/bin/qmltestrunner"; do
    if [ -x "$path" ]; then
        RUNNER="$path"
        break
    fi
done

if [ -z "$RUNNER" ] && command -v qmltestrunner &>/dev/null; then
    RUNNER="qmltestrunner"
fi

if [ -z "$RUNNER" ]; then
    echo "No 'qmltestrunner' found in standard locations or PATH." >&2
    echo "To proceed, install it via 'qt6-declarative' (Arch) or 'qt6-qtdeclarative-devel' (Fedora)" >&2
    exit 1
fi

# Headless: tests only exercise logic, no window needed
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}"
export QT_LOGGING_RULES="${QT_LOGGING_RULES:-qt.qpa.*=false}"

echo "==> QML unit tests (Tests/tst_*.qml)"
"$RUNNER" -input Tests "$@"

echo "==> Repository consistency tests (Tests/python)"
python3 -m unittest discover -s Tests/python
