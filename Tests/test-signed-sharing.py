#!/usr/bin/env python3
"""Check production defaults selection across signed host/sandbox probe processes.

Uses a unique temporary preference key in the supplied team's real app group.
Does not launch/register the actual Finder extension or alter user preferences.
"""
import argparse
import json
from pathlib import Path
import plistlib
import re
import subprocess
import tempfile
import uuid

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--team-id', required=True)
parser.add_argument('--identity', required=True)
args = parser.parse_args()
if not re.fullmatch(r'[A-Z0-9]{10}', args.team_id):
    parser.error('Invalid Team ID')
if not re.fullmatch(r'[A-Fa-f0-9]{40}', args.identity):
    parser.error('Use the signing identity SHA-1')
output = Path(tempfile.mkdtemp(prefix='oit-sharing-test-'))
constants = (ROOT / 'OpenInTerminalCore/Constants.swift').read_text().replace('C8VX3ZLX5U.', args.team_id + '.')
defaults = (ROOT / 'OpenInTerminalCore/Defaults.swift').read_text().split('public class DefaultsKeys')[0]
probe = r'''
let action = CommandLine.arguments[1]
let key = CommandLine.arguments[2]
let value = CommandLine.arguments[3]
// These probe bundle IDs intentionally do not trigger real-user migration.
guard defaultsConfiguration.persistentDomainName == Constants.Id.Group else {
    fputs("FAIL: selected per-process fallback instead of shared group\n", stderr)
    exit(1)
}
switch action {
case "write":
    Defaults.set(value, forKey: key)
    // Validate persistence through fresh reader processes, not this legacy return value.
    print("synchronize returned \(Defaults.synchronize())")
case "read":
    guard Defaults.string(forKey: key) == value else {
        fputs("FAIL: shared preference missing or incorrect\n", stderr)
        exit(3)
    }
case "clean":
    Defaults.removeObject(forKey: key)
    Defaults.synchronize()
default: exit(4)
}
print("PASS: \(action) using \(Constants.Id.Group)")
'''
source = output / 'main.swift'
source.write_text(constants + '\n' + defaults + '\n' + probe)
subprocess.run(['xcrun', 'swiftc', '-module-cache-path', str(output / 'cache'), str(source), '-o', str(output / 'probe')], check=True)
executables = []
for role, entpath in [('Host', 'OpenInTerminal/OpenInTerminal.entitlements'),
                      ('Sandbox', 'OpenInTerminalFinderExtension/OpenInTerminalFinderExtension.entitlements')]:
    bundle = output / (role + '.app')
    contents = bundle / 'Contents'
    executable = contents / 'MacOS/probe'
    executable.parent.mkdir(parents=True)
    subprocess.run(['ditto', str(output / 'probe'), str(executable)], check=True)
    (contents / 'Info.plist').write_bytes(plistlib.dumps({
        'CFBundleIdentifier': 'test.OpenInTerminal.' + role.lower() + '.' + uuid.uuid4().hex,
        'CFBundleExecutable': 'probe', 'CFBundlePackageType': 'APPL',
        'CFBundleName': 'OpenInTerminal Sharing ' + role,
        'CFBundleVersion': '1', 'CFBundleShortVersionString': '1.0', 'LSUIElement': True}))
    entitlements = output / (role + '.entitlements')
    entitlements.write_text((ROOT / entpath).read_text().replace('C8VX3ZLX5U.', args.team_id + '.'))
    subprocess.run(['codesign', '--force', '--options', 'runtime', '--timestamp', '--sign', args.identity,
                    '--entitlements', str(entitlements), str(bundle)], check=True)
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(bundle)], check=True)
    details = subprocess.run(['codesign', '-dv', '--verbose=4', str(bundle)], capture_output=True, text=True, check=True).stderr
    assert f'TeamIdentifier={args.team_id}\n' in details
    (output / (role + '.signature.txt')).write_text(details)
    executables.append(executable)
key = 'OIT_SharingProbe_' + uuid.uuid4().hex
value = uuid.uuid4().hex
results = []
try:
    for index, action, expected in [(0, 'write', value), (1, 'read', value),
                                    (1, 'write', value + '-sandbox'), (0, 'read', value + '-sandbox')]:
        result = subprocess.run([str(executables[index]), action, key, expected], check=False,
                                capture_output=True, text=True, timeout=30)
        results.append({'process': ['host', 'sandbox'][index], 'action': action,
                        'stdout': result.stdout, 'stderr': result.stderr, 'exit_code': result.returncode})
        (output / 'attempts.json').write_text(json.dumps(results, indent=2) + '\n')
        if result.returncode:
            raise RuntimeError(f'{action} failed: {result.stdout} {result.stderr}')
finally:
    subprocess.run([str(executables[0]), 'clean', key, value], check=False, timeout=30)
(output / 'results.json').write_text(json.dumps({'team_id': args.team_id, 'results': results,
    'scope': 'production preference selection and cross-process sharing; not actual Finder UI or upstream migration'}, indent=2) + '\n')
print(f'PASS: bidirectional sharing across fresh host/sandbox processes; evidence: {output}')
