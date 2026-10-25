#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/oit-preferences.XXXXXX")
# cfprefsd keeps an empty plist after removePersistentDomain, so delete the file too.
test_plist="$HOME/Library/Preferences/OpenInTerminal-tests-$(basename "$test_dir").plist"
trap 'rm -rf "$test_dir" "$test_plist"' EXIT
xcrun swiftc OpenInTerminalCore/Constants.swift OpenInTerminalCore/Defaults.swift \
  Tests/SharedPreferences/main.swift -o "$test_dir/preferences-tests"
"$test_dir/preferences-tests" "$test_dir"
"$test_dir/preferences-tests" "$test_dir" verify-relaunch
