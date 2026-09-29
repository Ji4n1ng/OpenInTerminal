# PR #281 review follow-up

Thanks @danyhoron and @shuch3ng for the detailed reports. This update addresses the [identifier and Finder-first migration feedback](https://github.com/Ji4n1ng/OpenInTerminal/pull/281#issuecomment-5827799679) while retaining the agreed scope.

## Changes addressing the review

- **One shared identifier:** the runtime constant and both entitlements now use `C8VX3ZLX5U.group.wang.jianing.app.OpenInTerminal`, consistent with #285. My original methodology followed Apple's supported macOS format, `<Developer team identifier>.<group name>`. Both suffixes fit that format; retaining `group.` in the name maintains uniformity with the project's naming and the related work. It does not make this the same container as the bare `group.wang.jianing.app.OpenInTerminal` identifier.
- **Host-only migration:** the Finder extension cannot copy preferences or mark migration complete. Version 2 repairs a previous version-1 completion marker, including the Finder-first case raised in review.
- **Preserve existing settings:** existing destination values win, including false and empty values. Missing recognized keys are recovered from the main app's fallback domain, the previous #281 Team-prefixed group, then the legacy bare group. The host retains the previous group entitlement for migration.
- **Reset remains reset:** clear recognized preferences from accessible migration sources, preventing old choices from returning after reset/restart. Unrelated source keys are preserved.

Apple [documents](https://developer.apple.com/documentation/xcode/accessing-app-group-containers) that this macOS Team-prefixed form is authorized by matching the prefix to the signing team's identifier, without App Group provisioning. Apple's current recommendation for provisioned identifiers beginning with `group.` is a distinct option. The added `group.` after our Team ID is a consistency choice, not an Apple requirement or proof of registration.

## Validation addressing the Finder report

The reviewers correctly identified that `UserDefaults.standard` creates separate host and sandboxed-extension stores. The public artifact remains **ad hoc–signed**, with no Apple Developer Team ID; its Finder actions may therefore use Terminal/TextEdit instead of the host's configured apps. See [the public build warning](ad-hoc-build.md). We do not present that artifact as validation of shared preferences.

I signed an isolated test build with **my own Developer ID Application identity**, separate from the app owner’s identity, and validated it on macOS 26.6.2 and macOS 27.0.1. Only test-copy group constants and entitlements were changed to match the testing team; upstream identifiers remain in the PR. Signatures passed before and after ZIP extraction, and fresh signed host/sandbox processes exchanged preferences in both directions.

On macOS 27, actual Finder toolbar/context actions used Zed; the user confirmed Ghostty opened the correct directory. Copy Path was checked, and the user confirmed physical shortcuts. A signed previous-container fixture verified that Finder-first startup left migration for the host. Actual Reset Preferences survived restart without resurrecting settings. After a power cycle, the app was already running, all three shortcut bindings persisted, and the user's chosen Terminal/Visual Studio Code selections remained. See [the macOS 27 report](macos27-validation.md) and [initial signed-test report](developer-id-validation.md) for evidence and limitations.

## Coordination and remaining checks

As agreed in the [scope discussion](https://github.com/Ji4n1ng/OpenInTerminal/pull/281#issuecomment-5824604467), dynamic signing-team support, renamed bundle identifiers, and deployment-target changes remain separate. #284 was closed in favor of #285, which is the coordination point. The project deployment target is unchanged; local Xcode 27 builds used a command-line `MACOSX_DEPLOYMENT_TARGET=12.0` override. This does not establish older macOS compatibility.

Separate-team testing supports the expectation that the same code works with matching upstream signatures and entitlements. The app owner needs to sign the production app and extension with the upstream Developer ID Application identity and matching App Group entitlements. Before merging, the maintainer still needs to validate that final upstream-signed build, including access to upstream-protected legacy preferences and upgrade migration. We cannot establish that authorization using another developer's identity. The signed test artifact was not notarized.
