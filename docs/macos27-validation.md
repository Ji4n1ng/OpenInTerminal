# macOS 27 validation checkpoint

Environment: macOS 27.0.1 (26A434), Apple silicon. Tests use my own Developer ID Application identity under a separate testing team and the existing signed test artifact SHA-256 bef14cc28cd36a882862264ff7789b6d72a895c5b5a74c0a98efee03cc4ab02f. This is a separate-team build; upstream identifiers remain unchanged in the PR sources. No new code changes were required during this run.

## Passed

- Selected-app persistence across power cycle: the signed post-reboot snapshot shows Terminal and Visual Studio Code. The user confirmed these were intentional changes to their preferred apps, resolving the difference from the earlier Ghostty/Zed test selections.

- Power-cycle/login startup: user reported a power cycle. Live system check showed boot September 28 at 22:47:33 and the existing test app process (PID 926) started at 22:48:07, before any UI helper or app-launch action by the agent. Installed signature was confirmed to match the separate testing identity.
- All three shortcut bindings persisted across the power cycle: Control-Option-Command-E, -T, and -C. Signed helper snapshot also shows migration version 2.

- Portable automated suite: kit integrity, app/helper signatures, migration/reset regression, bidirectional signed host/sandbox sharing, and cleanup.
- Actual app recognizes installed Ghostty and Zed and saves their selections.
- Finder toolbar shows Ghostty/Zed; its Zed action opens the test directory.
- Finder Ghostty action invoked; user explicitly confirmed it opened the correct test directory. Terminal UI inspection is blocked by the computer-use tool, so this outcome is user-confirmed.
- Finder context-menu Zed action opens probe.txt at the expected exact file URL.
- Finder toolbar Copy path pasted into an unsaved Zed buffer matches the test directory, with the space escaped.
- Physical shortcut execution: user confirmed the requested interactive tests worked as expected. Configured shortcuts are Control-Option-Command-E (Zed), Control-Option-Command-T (Ghostty), and Control-Option-Command-C (Copy path). The terminal and Copy path shortcuts were assigned from empty fields without relaunching. This is user-confirmed evidence; simulated keypresses did not independently establish the result.
- Signed previous-container migration with Finder first: stopped the host, placed FirstSetup and selected app preferences into the previous test-team container, seeded the destination with version-1 migration marker, and restarted Finder. A fresh extension ran while the host was absent; the destination remained at version 1 without app selections. Starting the actual host recovered Ghostty/Zed.
- Actual Reset Preferences returned to Terminal/TextEdit, cleared the selected apps from the old source, and remained at Terminal/TextEdit after host/Finder restart. No preferences resurrected.
- Restored the signed snapshot after these tests. Ghostty/Zed were selected again at that stage, before the user subsequently chose Terminal/Visual Studio Code. Launch at login was disabled by reset and was explicitly re-enabled in the UI.

The first migration fixture omitted FirstSetup, which triggered legitimate first-run defaults. That fixture was corrected to represent an existing installation; no product change was made to obtain the migration pass.

## Still pending

- Actual upstream release signing and upstream-protected legacy-container migration.
- Older supported OS runtime compatibility, notarization, and a new menu-bar action check.

## Reproduction and evidence boundaries

Run `python3 Tests/test-defaults-migration.py` for the isolated regression checks. Use `Tests/build-team-test.py` and `Tests/test-signed-sharing.py` with a valid Developer ID Application signing identity for the separate-team checks described in [the initial validation report](developer-id-validation.md). Test-only substitutions must match the signing team in both runtime constants and entitlements.

The exact signed artifact hash above identifies the build used in the interactive checks. The publicly downloadable ad hoc build is a different artifact and does not establish App Group authorization. Preference snapshots, personal app backups, and raw machine logs are retained locally and excluded from Git. The user confirmed intentionally selecting Terminal and Visual Studio Code before the final power cycle.

This report records completed tests, including explicitly user-confirmed observations; it does not guarantee upstream container access or replace the maintainer's final signed upgrade test.
