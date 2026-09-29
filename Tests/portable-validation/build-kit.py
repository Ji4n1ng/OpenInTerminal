#!/usr/bin/env python3
"""Maintainer-side kit packaging; the receiving Mac does not need Python/Xcode."""
import argparse
import ast
import hashlib
import plistlib
from pathlib import Path
import shutil
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--identity', required=True, help='Developer ID Application identity SHA-1')
parser.add_argument('--team-id', required=True)
parser.add_argument('--app-archive', type=Path, required=True)
args = parser.parse_args()
kit = root / 'outputs/OpenInTerminal-OS27-Validation-Kit'
if kit.exists():
    raise SystemExit('Kit directory already exists; preserve it before rebuilding.')
kit.mkdir()
identity=args.identity
team=args.team_id

def literal(path, name):
    tree=ast.parse(path.read_text())
    for item in tree.body:
        if isinstance(item,ast.Assign) and any(isinstance(t,ast.Name) and t.id==name for t in item.targets):
            return ast.literal_eval(item.value)
    raise ValueError(name)

constants=(root/'OpenInTerminalCore/Constants.swift').read_text().replace('C8VX3ZLX5U.',team+'.')
defaults=(root/'OpenInTerminalCore/Defaults.swift').read_text().split('public class DefaultsKeys')[0]
share=literal(root/'Tests/test-signed-sharing.py','probe')
migration=literal(root/'Tests/test-defaults-migration.py','tests')
with tempfile.TemporaryDirectory(prefix='oit-kit-build-') as tmp:
    tmp=Path(tmp)
    for role, source in [('Host',share),('Sandbox',share),('Migration',migration)]:
        swift=tmp/'main.swift'; swift.write_text(constants+'\n'+defaults+'\n'+source)
        binaries=[]
        for arch in ['arm64','x86_64']:
            binary=tmp/(role+'-'+arch)
            subprocess.run(['xcrun','swiftc','-Onone','-target',arch+'-apple-macos12.0','-module-cache-path',str(tmp/'cache'),str(swift),'-o',str(binary)],check=True)
            binaries.append(str(binary))
        bundle=kit/'Helpers'/(role+'.app'); contents=bundle/'Contents'
        executable=contents/'MacOS/probe'; executable.parent.mkdir(parents=True)
        subprocess.run(['xcrun','lipo','-create',*binaries,'-output',str(executable)],check=True)
        (contents/'Info.plist').write_bytes(plistlib.dumps({'CFBundleIdentifier':'test.OpenInTerminal.portable.'+role.lower(), 'CFBundleExecutable':'probe','CFBundlePackageType':'APPL','CFBundleName':role+' Validation','CFBundleVersion':'1','CFBundleShortVersionString':'1.0','LSUIElement':True,'LSMinimumSystemVersion':'12.0'}))
        ent={}
        if role!='Migration':
            name='OpenInTerminalFinderExtension/OpenInTerminalFinderExtension.entitlements' if role=='Sandbox' else 'OpenInTerminal/OpenInTerminal.entitlements'
            ent=plistlib.loads((root/name).read_text().replace('C8VX3ZLX5U.',team+'.').encode())
        entfile=tmp/(role+'.plist'); entfile.write_bytes(plistlib.dumps(ent))
        subprocess.run(['codesign','--force','--options','runtime','--timestamp','--sign',identity,'--entitlements',str(entfile),str(bundle)],check=True)
        subprocess.run(['codesign','--verify','--deep','--strict',str(bundle)],check=True)
(kit/'App').mkdir()
subprocess.run(['ditto','-x','-k',str(args.app_archive),str(kit/'App')],check=True)
for name in ['Run Validation.command','README.txt']:
    (kit/name).write_text((root/'Tests/portable-validation'/name).read_text().replace('TESTTEAMID', team))
    (kit/name).chmod((root/'Tests/portable-validation'/name).stat().st_mode)
lines=[]
for file in sorted(kit.rglob('*')):
    if file.is_file():
        lines.append(hashlib.sha256(file.read_bytes()).hexdigest()+'  '+str(file.relative_to(kit)))
(kit/'SHA256SUMS').write_text('\n'.join(lines)+'\n')
print(kit)
