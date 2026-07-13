---
name: release
description: Release a new version of OpenInTerminal, OpenInTerminal-Lite, and OpenInEditor-Lite — publish GitHub releases from ./export zips and open a Homebrew cask PR. Use when the user wants to "release", "publish a new version", "ship", or "update the brew casks" for these apps.
---

# Release process for OpenInTerminal

This repo ships three apps. Their releases and casks are grouped as follows:

| App | Zip in `./export` | GitHub release / tag | Homebrew cask |
| --- | --- | --- | --- |
| OpenInTerminal (main) | `OpenInTerminal.zip` | `OpenInTerminal vX.Y.Z` / `vX.Y.Z` | `openinterminal` |
| OpenInTerminal-Lite | `OpenInTerminal-Lite.zip` | `OpenInTerminal-Lite vA.B.C` / `vA.B.C` | `openinterminal-lite` |
| OpenInEditor-Lite | `OpenInEditor-Lite.zip` | (bundled in the Lite release above) | `openineditor-lite` |

**Two GitHub releases, not three:** the main app gets its own release; **both Lite apps ride together in the Lite release** (both zips attached to the `vA.B.C` tag). Confirm the version numbers with the user or read them from the changelogs — main app version is in `README.md` (`## Changes`), Lite version is in `Resources/README-Lite.md`. The user builds the `.app`s and zips into `./export` before invoking this.

## Prerequisites (check first)
- Zips exist: `ls ./export/*.zip` → the three zips above.
- `gh auth status` is authenticated for `Ji4n1ng/OpenInTerminal`.
- The Homebrew fork is checked out at `/Users/jianing/GitHub/homebrew-cask` (remote `origin` = `git@github.com:Ji4n1ng/homebrew-cask.git`).

## Step 1 — Inspect existing releases (match the house style)
```bash
gh release list --limit 6
gh release view <lastMainTag>  --json name,tagName,body,assets   # note asset names + note style
gh release view <lastLiteTag>  --json name,tagName,body,assets
```
Release-note bodies follow: a short greeting line (optional) + `Changes:` + a bulleted list drawn from the README/README-Lite changelog for that version.

## Step 2 — Compute checksums
```bash
cd ./export && shasum -a 256 OpenInTerminal.zip OpenInTerminal-Lite.zip OpenInEditor-Lite.zip
```
Keep these — the cask sha256 values must equal the sha256 of the **uploaded** assets.

## Step 3 — Pre-flight the tags
```bash
git ls-remote --tags origin vX.Y.Z vA.B.C      # must be empty (tags must not already exist)
git fetch origin master -q && git rev-parse HEAD && git rev-parse origin/master   # release tags point at origin/master
```

## Step 4 — Create the two releases
`--target` **must be a full 40-char commit SHA or a branch name** — a short SHA fails with `Release.target_commitish is invalid`.
```bash
FULL=$(git rev-parse HEAD)
gh release create vX.Y.Z --title "OpenInTerminal vX.Y.Z" --target "$FULL" \
  --notes-file notes-terminal.md  export/OpenInTerminal.zip
gh release create vA.B.C --title "OpenInTerminal-Lite vA.B.C" --target "$FULL" \
  --notes-file notes-lite.md      export/OpenInTerminal-Lite.zip export/OpenInEditor-Lite.zip
```
GitHub auto-marks the most recently published release as "Latest". By convention the **main app** is Latest, so fix it:
```bash
gh release edit vX.Y.Z --latest
```
Verify assets: `gh release view vX.Y.Z --json assets -q '[.assets[].name]'` (note: this `gh` build has no `isLatest` JSON field — use `gh release list` to see the Latest marker).

## Step 5 — Verify the uploads before touching Homebrew
Download each asset from its release URL and confirm the sha256 matches step 2 — this catches a corrupted upload and guarantees the cask checksums are correct:
```bash
curl -sL -o dl.zip "https://github.com/Ji4n1ng/OpenInTerminal/releases/download/vX.Y.Z/OpenInTerminal.zip"
shasum -a 256 dl.zip
```

## Step 6 — Homebrew cask PR
The fork's default branch is `master`; **upstream `Homebrew/homebrew-cask`'s default branch is `main`** (not master). Base the PR branch on fresh upstream `main`:
```bash
cd /Users/jianing/GitHub/homebrew-cask
git remote add upstream https://github.com/Homebrew/homebrew-cask.git   # once
git fetch upstream main --quiet
git checkout -b openinterminal-X.Y.Z upstream/main
```
Cask files live under `Casks/o/`: `openinterminal.rb`, `openinterminal-lite.rb`, `openineditor-lite.rb`. In each, edit **only** the `version` and `sha256` lines (the `url` uses `v#{version}`, so it tracks automatically). Commit one cask per commit, Homebrew style `<cask> <version>`:
```
openinterminal 2.3.9
openinterminal-lite 1.2.8
openineditor-lite 1.2.8
```
Validate locally:
```bash
brew style Casks/o/openinterminal.rb Casks/o/openinterminal-lite.rb Casks/o/openineditor-lite.rb   # must be clean
```
`brew audit` only runs by **cask name inside a tap**, not by path. To run the real online audit, force-tap and swap the files in:
```bash
brew tap --force homebrew/cask                       # ~560MB clone
TAP="$(brew --repository)/Library/Taps/homebrew/homebrew-cask"
cp Casks/o/openin*.rb "$TAP/Casks/o/"
brew audit --cask --online openinterminal openinterminal-lite openineditor-lite
cd "$TAP" && git checkout -- Casks/o/openin*.rb       # restore tap afterward
```
Push to the fork and open the PR against `Homebrew/homebrew-cask` base `main`:
```bash
git push -u origin openinterminal-X.Y.Z
gh pr create --repo Homebrew/homebrew-cask --base main --head Ji4n1ng:openinterminal-X.Y.Z \
  --title "..." --body-file pr-body.md
```

### The PR template is mandatory and bot-enforced
A bot auto-closes any PR that doesn't use the **current** template verbatim, and auto-reopens it once the body is complete. Fetch the live template and fill it honestly (do NOT tick a box for an action you didn't perform):
```bash
git show upstream/main:.github/PULL_REQUEST_TEMPLATE.md
```
- Tick "stable version" and "`brew style --fix` reports no offenses".
- The "new cask" section is N/A for version bumps — leave unticked.
- There is an **AI-disclosure checkbox** — tick it and describe how AI helped + manual verification (including that `zap` paths are unchanged).
- Edit the body with `gh pr edit <num> --repo Homebrew/homebrew-cask --body-file ...`; the reopen workflow runs within ~1 min.

## Known blockers / gotchas
- **Signing is a hard wall.** `homebrew/cask` requires every app to be **Developer-ID signed AND notarized**. `brew audit --cask --online` and CI `test` jobs fail with *"not signed by a distributor that meets the system Gatekeeper requirements… requires all casks to be signed and notarized by Apple."* Check the artifacts first:
  ```bash
  codesign -dv export/OpenInTerminal.app 2>&1 | grep -iE 'Signature|TeamIdentifier'   # adhoc / not set == will fail
  spctl -a -t exec -vv export/OpenInTerminal.app                                        # "rejected" == will fail
  ```
  Ad-hoc signed builds cannot pass. To fix: re-sign with Developer ID, `xcrun notarytool submit` + `xcrun stapler staple`, re-zip, re-upload to the releases, recompute sha256, update casks. If signed builds aren't available, warn the user the Homebrew PR will fail CI and won't merge — the GitHub releases still work for direct download.
- **One cask per PR:** Homebrew prefers a single cask per PR; a three-cask PR gets an `automerge-skip` label and a "must not modify multiple casks" note. Maintainers may ask to split into three. Do the combined PR only if the user explicitly wants one PR.
- **Cleanup:** the force-tap adds ~560MB; offer `brew untap --force homebrew/cask` when done.

## Deliverables to report
Release URLs (both), Latest marker set on the main release, PR URL and its CI state, plus any blocker (signing) surfaced clearly.
