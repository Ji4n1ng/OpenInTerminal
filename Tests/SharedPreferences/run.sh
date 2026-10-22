#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/oit-preferences.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT
xcrun swiftc OpenInTerminalCore/Constants.swift OpenInTerminalCore/Defaults.swift \
  Tests/SharedPreferences/main.swift -o "$test_dir/preferences-tests"
"$test_dir/preferences-tests" "$test_dir"
"$test_dir/preferences-tests" "$test_dir" verify-relaunch
