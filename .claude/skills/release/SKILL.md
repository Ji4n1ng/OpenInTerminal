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

**Two GitHub releases, not three:** the main app gets its own release; **both Lite apps ride together in the Lite release** (both zips attached to the `vA.B.C` tag). Confirm the version numbers with the user or read them from the changelogs — main app version is in `README.md` (`## Changes`), Lite version is in `Resources/README-Lite.md`.

**Artifacts must be Developer-ID signed AND notarized** (Homebrew rejects anything else — see Step 0). Do not release ad-hoc/`build-unsigned.sh` output to GitHub or Homebrew.

## Prerequisites (check first)
- `gh auth status` is authenticated for `Ji4n1ng/OpenInTerminal`.
- The Homebrew fork is checked out at `/Users/jianing/GitHub/homebrew-cask` (remote `origin` = `git@github.com:Ji4n1ng/homebrew-cask.git`).

## Step 0 — Build signed + notarized artifacts
Run `./build-signed.sh` (repo root). It Developer-ID signs (hardened runtime + timestamp), submits to Apple's notary service, staples, and writes `export/<App>.zip` for all three apps. Needs the `Developer ID Application: Jianing Wang (C8VX3ZLX5U)` cert and the `OpenInTerminal-notary` keychain profile — both already set up; the script auto-detects them and fails fast if missing. (`build-unsigned.sh` is local-testing only — never release its output.)

Verify each built app before releasing:
```bash
for a in OpenInTerminal OpenInTerminal-Lite OpenInEditor-Lite; do
  spctl -a -t exec -vv "export/$a.app"      # must say: accepted / source=Notarized Developer ID
  xcrun stapler validate "export/$a.app"    # must say: The validate action worked!
done
ls ./export/*.zip                            # the three zips above must exist
```

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

**Re-releasing an existing tag** (e.g. replacing unsigned assets with signed ones): don't create — clobber the assets in place. Tags/notes stay untouched:
```bash
gh release upload vX.Y.Z export/OpenInTerminal.zip --clobber
gh release upload vA.B.C export/OpenInTerminal-Lite.zip export/OpenInEditor-Lite.zip --clobber
```
Large uploads (the main zip is ~25MB) can take minutes — run in the background and wait. The API-reported `digest` (`gh release view … --json assets`) is the server-side sha256 of the stored asset, so it's authoritative for the cask checksums.

## Step 5 — Verify the uploads before touching Homebrew
Download each asset from its release URL and confirm the sha256 matches step 2 — this catches a corrupted upload and guarantees the cask checksums are correct. Also unzip and re-check Gatekeeper on the downloaded artifact, so you know notarization survived the round-trip (this is what users receive):
```bash
curl -sL -o dl.zip "https://github.com/Ji4n1ng/OpenInTerminal/releases/download/vX.Y.Z/OpenInTerminal.zip"
shasum -a 256 dl.zip
ditto -x -k dl.zip dl && spctl -a -t exec -vv dl/OpenInTerminal.app   # accepted / source=Notarized Developer ID
```

## Step 6 — Homebrew cask PR
The fork's default branch is `master`; **upstream `Homebrew/homebrew-cask`'s default branch is `main`** (not master). Base the PR branch on fresh upstream `main`:
```bash
cd /Users/jianing/GitHub/homebrew-cask
git remote add upstream https://github.com/Homebrew/homebrew-cask.git   # once
git fetch upstream main --quiet
git checkout -b openinterminal-X.Y.Z upstream/main
```
**Reusing an existing PR branch** (e.g. re-pushing signed builds onto an open PR): recreate it fresh from current `upstream/main`, don't rebase the stale tip — then force-push (`git push --force-with-lease`). The PR keeps its number and thread.
```bash
git checkout -f upstream/main && git branch -D openinterminal-X.Y.Z
git checkout -b openinterminal-X.Y.Z upstream/main   # now apply the cask edits below
```
⚠️ Do **not** `git reset --soft upstream/main` from the old branch tip to "move" it forward — the old tip's tree is stale, so the reset stages the entire upstream divergence (hundreds of unrelated casks). Always recreate the branch from a fresh `upstream/main` checkout as above.
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
- Tick "stable version", "`brew style --fix` reports no offenses", and — with Step-0 notarized artifacts — "`brew audit --cask --online` is error-free" (run the audit below first; only tick if it actually passes).
- The "new cask" section is N/A for version bumps — leave unticked.
- There is an **AI-disclosure checkbox** — tick it and describe how AI helped + manual verification (including that `zap` paths are unchanged).
- Edit the body with `gh pr edit <num> --repo Homebrew/homebrew-cask --body-file ...`; the reopen workflow runs within ~1 min.

## Known blockers / gotchas
- **Signing/notarization** — `homebrew/cask` requires every app to be **Developer-ID signed AND notarized**; ad-hoc builds fail `brew audit --cask --online` and CI `test` jobs with *"not signed by a distributor that meets the system Gatekeeper requirements."* This is handled by Step 0 (`build-signed.sh` → notarized artifacts), so it is no longer a blocker as long as you release Step-0 output. If you ever see the Gatekeeper failure, the artifacts are unsigned/ad-hoc — rebuild via Step 0, don't hand-patch. (History: v2.3.9/v1.2.8 first shipped ad-hoc and were rejected in [PR #274726](https://github.com/Homebrew/homebrew-cask/pull/274726); re-uploading notarized builds made CI pass.)
- **One cask per PR:** Homebrew prefers a single cask per PR; a three-cask PR gets an `automerge-skip` label and a "must not modify multiple casks" note. Maintainers may ask to split into three. Do the combined PR only if the user explicitly wants one PR.
- **Cleanup:** the force-tap adds ~560MB; offer `brew untap --force homebrew/cask` when done.

## Deliverables to report
Release URLs (both), Latest marker set on the main release, PR URL and its CI state, plus any blocker (signing) surfaced clearly.
