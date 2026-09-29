#!/usr/bin/env python3
"""Build an isolated Developer ID test artifact without changing upstream sources.

Does not install, launch, notarize, publish, or export private keys.
"""
import argparse
import hashlib
import json
import plistlib
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM = 'C8VX3ZLX5U'
SUBSTITUTIONS = (
    'OpenInTerminalCore/Constants.swift',
    'OpenInTerminal/OpenInTerminal.entitlements',
    'OpenInTerminalFinderExtension/OpenInTerminalFinderExtension.entitlements',
)


def run(args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)


def prepare(destination, team):
    # Copy current tracked files, including uncommitted edits, not just HEAD.
    files = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).split(b'\0')
    for raw in files:
        if not raw:
            continue
        relative = Path(raw.decode())
        source = ROOT / relative
        if source.is_file():
            target = destination / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
    for relative in SUBSTITUTIONS:
        path = destination / relative
        path.write_text(path.read_text().replace(UPSTREAM + '.', team + '.'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--team-id', required=True)
    parser.add_argument('--identity', help='SHA-1 of a valid Developer ID Application identity')
    parser.add_argument('--deployment-target', help='Optional build-only compatibility override')
    parser.add_argument('--prepare-only', action='store_true')
    args = parser.parse_args()
    if not re.fullmatch(r'[A-Z0-9]{10}', args.team_id):
        parser.error('team-id must be a ten-character Apple Team ID')
    if not args.prepare_only:
        if not args.identity or not re.fullmatch(r'[A-Fa-f0-9]{40}', args.identity):
            parser.error('identity must be the SHA-1 of a Developer ID Application identity')
        identities = subprocess.check_output(['security', 'find-identity', '-v', '-p', 'codesigning'], text=True)
        if not any(args.identity.upper() in line.upper() and '"Developer ID Application:' in line
                   for line in identities.splitlines()):
            parser.error('the specified valid Developer ID Application identity was not found')
    output = Path(tempfile.mkdtemp(prefix='oit-team-test-'))
    source = output / 'source'
    prepare(source, args.team_id)
    evidence = {'team_id': args.team_id, 'substituted_files': list(SUBSTITUTIONS),
                'source_revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                'source_includes_working_changes': True,
                'deployment_target_override': args.deployment_target,
                'runtime_validation': 'not performed', 'notarization': 'not performed'}
    (output / 'source.patch').write_bytes(subprocess.check_output(['git', 'diff', '--binary'], cwd=ROOT))
    print(f'Test directory: {output}', flush=True)
    if args.prepare_only:
        evidence['status'] = 'source prepared only; not built or signed'
        (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
        return
    build = ['xcodebuild', '-workspace', 'OpenInTerminal.xcworkspace', '-scheme', 'OpenInTerminal',
             '-configuration', 'Release', '-derivedDataPath', str(output / 'build'),
             '-destination', 'generic/platform=macOS', 'CODE_SIGNING_ALLOWED=NO']
    if args.deployment_target:
        build.append('MACOSX_DEPLOYMENT_TARGET=' + args.deployment_target)
    with (output / 'build.log').open('w') as log:
        run(build + ['build'], cwd=source, stdout=log, stderr=subprocess.STDOUT)
    products = output / 'build/Build/Products/Release'
    app = output / 'OpenInTerminal.app'
    run(['ditto', '--norsrc', '--noextattr', str(products / 'OpenInTerminal.app'), str(app)])
    helper = products / 'OpenInTerminalHelper.app'
    if helper.exists():
        run(['ditto', '--norsrc', '--noextattr', str(helper),
             str(app / 'Contents/Library/LoginItems/OpenInTerminalHelper.app')])
    common = ['codesign', '--force', '--options', 'runtime', '--timestamp', '--sign', args.identity]
    # Sign contained code before enclosing bundles.
    for pattern in ('*.dylib', '*.framework', '*.appex', '*.app'):
        for path in sorted(app.rglob(pattern), key=lambda p: len(p.parts), reverse=True):
            ent = []
            if path.suffix == '.appex':
                ent = ['--entitlements', str(source / SUBSTITUTIONS[2])]
            run(common + ent + [str(path)])
    run(common + ['--entitlements', str(source / SUBSTITUTIONS[1]), str(app)])
    run(['codesign', '--verify', '--deep', '--strict', str(app)])
    group = args.team_id + '.group.wang.jianing.app.OpenInTerminal'
    for path in [app, *app.rglob('*.appex')]:
        details = subprocess.run(['codesign', '-dv', '--verbose=4', str(path)], check=True,
                                 capture_output=True, text=True).stderr
        if f'TeamIdentifier={args.team_id}\n' not in details:
            raise RuntimeError('Signing identity does not match requested Team ID')
        entitlements = plistlib.loads(subprocess.check_output(['codesign', '-d', '--entitlements', ':-', str(path)]))
        if group not in entitlements.get('com.apple.security.application-groups', []):
            raise RuntimeError('Shared group missing from signed entitlements')
        (output / (path.name + '.signature.txt')).write_text(details)
        (output / (path.name + '.entitlements.plist')).write_bytes(plistlib.dumps(entitlements))
    archive = output / 'OpenInTerminal-team-test.zip'
    run(['ditto', '-c', '-k', '--norsrc', '--noextattr', '--keepParent', str(app), str(archive)])
    extracted = output / 'extracted'
    run(['ditto', '-x', '-k', str(archive), str(extracted)])
    run(['codesign', '--verify', '--deep', '--strict', str(extracted / app.name)])
    evidence.update(status='built and signed; runtime validation pending',
                    archive=str(archive), sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),
                    shared_group=group, signature_checks='passed before and after ZIP extraction')
    (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    print(json.dumps(evidence, indent=2))


if __name__ == '__main__':
    main()
