OpenInTerminal — macOS 27 validation kit

No OpenAI, Xcode, Python, or developer certificate is needed on the test Mac.
All executables include Apple silicon and Intel code. The app and helpers are
signed using testing team TESTTEAMID. No private signing key is included.
They are not notarized. If macOS blocks execution, retain the message in your
report; do not disable Gatekeeper or remove quarantine as part of this test.

1. Copy this entire ZIP to the other Mac and extract it into a writable folder.
2. Double-click Run Validation.command. Keep the Helpers and App folders beside
   it. It first checks the package, signatures, isolated migration/reset logic,
   and shared preferences across signed sandboxed and unsandboxed processes.
3. For actual Finder tests, back up your existing OpenInTerminal.app, quit it,
   and install this kit's App/OpenInTerminal.app in /Applications. The script
   pauses before those tests so you can do this, or skip them with n.
4. Follow the printed Finder instructions. Enter p only for a result you saw,
   f for failure, or s to skip. Pick a non-default editor if available.
5. A report ZIP appears on the Desktop. Send that ZIP back in this chat.
   It contains a summary, detailed log, and the disposable Finder test file.
6. Restore your original app afterward if you want to end the test installation.

Automated checks only (no install or Finder registration):
  /bin/bash "Run Validation.command" --automated-only
Run this from the extracted kit folder, or supply the script's full path.

The script does not install or replace apps, reset real preferences, request
admin privileges, upload data, or alter security settings. It does register
and enable the installed Finder extension if you confirm the manual section;
it optionally restarts that extension after asking. Migration/reset tests use
random temporary preference domains. Sharing uses one unique test key, removed
on normal exit or interruption. SIGKILL/power loss can prevent cleanup.

Logs avoid preference dumps, screenshots, serial numbers, and unrelated system
logs. Home-directory usernames in log paths are redacted. Certificate signing
names and Team IDs are included. Please review the report before sharing.

If the script itself cannot start, send the exact error text instead. If a
helper is blocked, the script records a failure and still writes the report.
An entirely disconnected Mac may be unable to obtain Apple's trust/revocation
information; include that error rather than treating it as an app regression.

Passes apply to the testing team. They do not establish access to the upstream
team's old containers, final release signing/notarization, reboot/login behavior,
or actual upgrade migration. Finder checks are explicitly user-reported; the
script cannot infer success just because it launched an app. Terminal or editor
choices unavailable on the test Mac should be marked skipped.
