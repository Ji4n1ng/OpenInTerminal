# Separate-team Developer ID validation

This report records the initial macOS 26 session. Subsequent macOS 27 testing, including Ghostty/Zed, shortcuts, reset, migration, and power-cycle persistence, is documented in [macOS 27 validation](macos27-validation.md). Limitations below describe the initial session only.

## Environment and artifact

- Tested September 28, 2026, on macOS **26.6.2 (25G83)**, Apple silicon.
- Xcode 27.0 (27A266a); Release build with a command-line macOS 12 deployment-target override. The project deployment target is unchanged.
- Signed with my own Developer ID Application identity, separate from the upstream identity. Personal signing identifiers are omitted.
- Current working changes based on `d29d00de226c151627c519c90eaa78f412641aa4`; the exact tracked source patch is saved with the local evidence.
- Test-only substitutions: Team ID in core group constants and app/extension entitlements. The PR's original source files retain the upstream Team ID.
- Archive: `outputs/developer-id-validation/OpenInTerminal-team-test.zip`.
- SHA-256: `bef14cc28cd36a882862264ff7789b6d72a895c5b5a74c0a98efee03cc4ab02f`.
- Signed, **not notarized**; this is a local test artifact.

## Passed

1. Release build and strict deep code-signature verification, including verification after ZIP extraction. App and Finder extension signatures both identify the testing team and declare its shared group.
2. Signed cross-process test using the production defaults-selection code: unsandboxed host writes, a fresh sandboxed process reads, sandbox writes, and a fresh host reads. Both processes selected the shared suite, not per-process fallback. The unique test preference was removed afterward.
3. Actual signed app temporarily installed at `/Applications/OpenInTerminal.app`; its extension was explicitly registered and enabled. Its signature was inspected to rule out accidentally testing the existing upstream app.
4. In app Preferences, selected Visual Studio Code. Finder's context menu displayed that selection and opened `Finder Test/probe.txt` in Visual Studio Code, with the exact file URL visible in the editor.
5. Restarted the app and Finder extension. Preferences still showed Visual Studio Code; Finder's toolbar menu still offered Visual Studio Code. Invoking it opened the `Finder Test` directory in the editor, with `probe.txt` visible in the Explorer.
6. Isolated production-function regression suite passes: host-only migration, old migration-marker recovery, source precedence, destination preservation, persistence, idempotence, reset, and self-source exclusion.
7. Original upstream-signed installation restored, strict signature verification passed, Finder extension re-registered, and original app reopened. Original app backup retained locally.

The first cross-process harness attempt treated a false return from `UserDefaults.synchronize()` as failure. Fresh host and sandbox readers nevertheless read the value correctly. The harness now checks observable cross-process persistence; final results record the return value without using it as the pass criterion. No production code was changed to obtain this pass.

## Not established by these tests

- macOS 27 runtime behavior: the current machine runs 26.6.2.
- Access to upstream-protected containers, real upstream upgrade migration, or the maintainer's final signing/notarization configuration.
- Ghostty/Zed specifically: they were not installed. Visual Studio Code provided a real non-default editor test.
- Terminal destination directory: its Finder toolbar action was invoked, but computer-use restrictions prevented inspection of Terminal's window.
- New reboot/login-launch validation, shortcut validation, clipboard content verification, or actual-app Reset Preferences. Reset was tested only through the isolated regression suite, to avoid clearing real legacy preferences.
- Signed migration with seeded legacy containers and Finder-first startup ordering: only the isolated migration regression covers that ordering, not a full signed upgrade installation.
- Older macOS runtime compatibility.

## Suggested PR validation wording

Validated a Developer ID-signed test build under a separate Apple Developer team on macOS 26.6.2. Only the Team ID in the shared-group constants and app/extension entitlements was substituted in an isolated copy; upstream identifiers remain unchanged in this PR. Strict signatures passed before and after packaging. Signed host/sandbox processes shared preferences successfully, and the actual Finder context menu and toolbar honored the configured Visual Studio Code editor, including after app/extension restart. Migration/reset regression checks also pass.

Upstream builds use the same Team-prefixed authorization mechanism and are expected to behave equivalently when signed with matching upstream entitlements. This does not replace upstream-signed upgrade/migration verification or a fresh macOS 27 runtime test. The test artifact was not notarized.

## Portable macOS 27 kit

`outputs/OpenInTerminal-OS27-Validation-Kit.zip` bundles the signed test app, universal signed host/sandbox/migration probes, a Bash runner, and instructions. The receiving Mac needs no OpenAI, Python, Xcode, or developer certificate. SHA-256: `6a40a2d99eae7b31b0af9d1cb8c71197cd67c98de4d6371d9b01de077e25fda1`.

Locally validated automated-only operation, including ZIP report creation, isolated migration/reset assertions, bidirectional signed preference sharing, and key cleanup. Signatures also pass after extracting the final ZIP when checked outside the agent filesystem sandbox. Actual Finder observations are logged as USER-REPORTED, separate from automated passes. The kit does not install/replace the app or reset real preferences. It optionally registers/enables the installed test extension and restarts it after user confirmation. All binaries remain signed but not notarized. The subsequent macOS 27 run passed; see the linked macOS 27 report.
