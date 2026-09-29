# Ad hoc test build: Finder shared-preferences limitation

**This download is ad hoc–signed (`codesign --sign -`), has no Apple Developer Team ID, and is not notarized. It is not signed with the contributor's Developer ID certificate.**

The main app can use its per-process preferences fallback, but the sandboxed Finder Sync extension has a separate fallback store. **Finder is therefore expected not to honor the main app's selected terminal/editor in this build** and may use Terminal/TextEdit instead. Loading the extension alone does not validate shared preferences.

For Finder to share these settings, both the app and extension need valid code signatures from the same Apple Developer team, matching `com.apple.security.application-groups` entitlements, and access to the declared App Group. For distribution outside the Mac App Store, the appropriate identity is **Developer ID Application**. This PR's unchanged production configuration requires upstream team `C8VX3ZLX5U`; merely signing it with another team's certificate is insufficient. Separate-team testing substituted matching identifiers only in an isolated source copy.

Apple explains the Team-prefixed authorization rule in [Accessing app group containers](https://developer.apple.com/documentation/xcode/accessing-app-group-containers). Ad hoc signatures provide no team identity to authorize this group. Notarization is a separate distribution check and does not repair mismatched App Group identifiers.

This experimental build is for main-app testing, not a replacement for the upstream-signed Finder validation. macOS may block a downloaded, unnotarized app. The signed integration results in [the validation report](macos27-validation.md) refer to a different, locally tested artifact; that personally signed artifact is not included in this release.

The release build uses Xcode 27 with a build-only macOS 12 deployment-target override, contains arm64 and x86_64 code, and leaves the repository's minimum OS unchanged. Older OS runtime compatibility is unverified.
