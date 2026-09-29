#!/bin/bash
# Built-in macOS tools plus bundled signed executables; no Python/Xcode required.
set -u
KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/OpenInTerminal-validation.XXXXXX")"
LOG="$REPORT_DIR/validation.log"
SUMMARY="$REPORT_DIR/summary.txt"
AUTO=0; [[ "${1:-}" == --automated-only ]] && AUTO=1
: > "$LOG"; : > "$SUMMARY"
RESULT=0; STARTED=0
HOST="$KIT_DIR/Helpers/Host.app/Contents/MacOS/probe"
SANDBOX="$KIT_DIR/Helpers/Sandbox.app/Contents/MacOS/probe"
KEY="OIT_SharingProbe_$(uuidgen)"; VALUE="$(uuidgen)"
say() { printf '%s\n' "$*" | tee -a "$LOG"; }
record() { printf '%s\n' "$*" | tee -a "$SUMMARY" "$LOG"; }
check() {
 local label="$1"; shift
 say "CHECK: $label"
 "$@" >> "$LOG" 2>&1
 local status=$?
 if [[ $status -eq 0 ]]; then record "PASS: $label"; else record "FAIL: $label (exit $status)"; RESULT=1; fi
 return "$status"
}
answer() {
 local label="$1" reply
 printf '%s [p=pass / f=fail / s=skip]: ' "$label"
 IFS= read -r reply || reply=s
 case "$reply" in
 p|P) record "USER-REPORTED PASS: $label";;
 f|F) record "USER-REPORTED FAIL: $label"; RESULT=1;;
 *) record "NOT TESTED: $label";; esac
}
finish() {
 trap - EXIT INT TERM
 if [[ "$STARTED" -eq 1 ]]; then check 'Remove unique sharing-test preference' "$HOST" clean "$KEY" "$VALUE" || true; fi
 say 'Scope: separate-team tests; upstream signing and upstream container migration remain separate checks.'
 for file in "$LOG" "$SUMMARY"; do
  sed -E 's#/Users/[^/[:space:]]+#/Users/USER#g' "$file" > "$file.redacted"
  mv "$file.redacted" "$file"
 done
 local archive="$HOME/Desktop/OpenInTerminal-validation-$(date +%Y%m%d-%H%M%S)-$$.zip"
 if ! ditto -c -k --norsrc --noextattr --keepParent "$REPORT_DIR" "$archive"; then
  archive="$REPORT_DIR.zip"; ditto -c -k --norsrc --noextattr --keepParent "$REPORT_DIR" "$archive"
 fi
 printf '\nReport to send back:\n%s\n' "$archive"
 [[ "$AUTO" -eq 0 ]] && { printf 'Press Return to close. '; IFS= read -r _ || true; }
}
trap finish EXIT
trap 'record "INTERRUPTED: validation did not finish"; exit 130' INT TERM
say 'OpenInTerminal portable validation v1'
date -u '+UTC: %Y-%m-%dT%H:%M:%SZ' >> "$LOG"
sw_vers >> "$LOG"; uname -m >> "$LOG"
say 'Testing team TESTTEAMID; upstream team C8VX3ZLX5U.'
say 'No automatic installation, real-preferences reset, security-setting changes, or network upload.'
say 'Signed helpers use disposable preference domains and one unique shared key.'
[[ "$(sw_vers -productVersion)" != 27.* ]] && record 'NOTE: this run is not on macOS 27'
check 'Kit file integrity' bash -c 'cd "$1" && shasum -a 256 -c SHA256SUMS' _ "$KIT_DIR" || exit 1
for role in Host Sandbox Migration; do
 check "$role helper signature" codesign --verify --deep --strict "$KIT_DIR/Helpers/$role.app" || exit 1
 codesign -dv --verbose=2 "$KIT_DIR/Helpers/$role.app" >> "$LOG" 2>&1
 codesign -d --entitlements :- "$KIT_DIR/Helpers/$role.app" >> "$LOG" 2>&1
done
check 'Bundled test app signature' codesign --verify --deep --strict "$KIT_DIR/App/OpenInTerminal.app" || exit 1
check 'Migration/reset regression (isolated fixtures)' "$KIT_DIR/Helpers/Migration.app/Contents/MacOS/probe" || true
STARTED=1
if check 'Host writes unique shared preference' "$HOST" write "$KEY" "$VALUE"; then
 check 'Fresh sandbox reads host preference' "$SANDBOX" read "$KEY" "$VALUE" || true
fi
if check 'Sandbox writes unique shared preference' "$SANDBOX" write "$KEY" "$VALUE-sandbox"; then
 check 'Fresh host reads sandbox preference' "$HOST" read "$KEY" "$VALUE-sandbox" || true
fi
if [[ "$AUTO" -eq 1 ]]; then record 'NOT TESTED: actual Finder UI (automated-only)'; exit "$RESULT"; fi
say 'Finder tests require this kit’s App/OpenInTerminal.app installed as /Applications/OpenInTerminal.app.'
say 'Back up the existing app first and quit it before copying the test app into Applications.'
say 'The app and helpers are signed but not notarized. Record any macOS blocking message; do not disable Gatekeeper.'
printf 'Is the test app installed and ready? [y/N]: '; IFS= read -r ready || ready=n
if [[ "$ready" != y && "$ready" != Y ]]; then record 'NOT TESTED: actual Finder UI (installation not confirmed)'; exit "$RESULT"; fi
APP=/Applications/OpenInTerminal.app
check 'Installed app signature' codesign --verify --deep --strict "$APP" || exit 1
EXPECTED="$(shasum -a 256 "$KIT_DIR/App/OpenInTerminal.app/Contents/MacOS/OpenInTerminal" | cut -d ' ' -f 1)"
ACTUAL="$(shasum -a 256 "$APP/Contents/MacOS/OpenInTerminal" | cut -d ' ' -f 1)"
if [[ "$EXPECTED" != "$ACTUAL" ]]; then record 'FAIL: installed executable differs from this kit'; exit 1; fi
codesign -dv --verbose=4 "$APP" >> "$LOG" 2>&1
if ! codesign -dv --verbose=4 "$APP" 2>&1 | grep -q '^TeamIdentifier=TESTTEAMID$'; then record 'FAIL: wrong installed signing team'; exit 1; fi
check 'Register installed Finder extension' pluginkit -a "$APP/Contents/PlugIns/OpenInTerminalFinderExtension.appex" || true
check 'Enable installed Finder extension' pluginkit -e use -i wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension || true
pluginkit -m -v -i wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension >> "$LOG" 2>&1
open -a "$APP"
mkdir -p "$REPORT_DIR/Finder Test"
printf 'OpenInTerminal portable Finder test.\n' > "$REPORT_DIR/Finder Test/probe.txt"
say 'Choose a non-default editor (VS Code or Zed) in app Preferences, and an alternate terminal if installed.'
printf 'Selected editor (or skip): '; IFS= read -r choice || choice=skip
say "USER-REPORTED selected editor: $choice"
open -R "$REPORT_DIR/Finder Test/probe.txt"
say 'Right-click probe.txt. Choose the OpenInTerminal editor action, not Finder’s normal Open With submenu.'
answer 'Context menu opens probe.txt in the selected editor'
say 'Use the OpenInTerminal Finder toolbar menu.'
answer 'Toolbar editor action opens Finder Test in the selected editor'
answer 'Toolbar terminal action opens a terminal in Finder Test'
say 'Use Copy path and paste into an empty editor document to inspect the value.'
answer 'Copy path produces the expected test path'
say 'Quit and reopen OpenInTerminal; check the selected editor.'
answer 'Editor preference survives app restart'
printf 'Restart only the OpenInTerminal Finder extension for a persistence check? [y/N]: '
IFS= read -r restart || restart=n
if [[ "$restart" == y || "$restart" == Y ]]; then
 pkill -x OpenInTerminalFinderExtension >> "$LOG" 2>&1 || true
 open -R "$REPORT_DIR/Finder Test/probe.txt"
 answer 'Restarted extension opens the correct folder in the selected editor'
else record 'NOT TESTED: extension restart'; fi
say 'Restore your original app afterward if this was a temporary installation.'
record 'NOT TESTED BY SCRIPT: reboot/login launch, actual upstream upgrade migration, older macOS compatibility'
exit "$RESULT"
