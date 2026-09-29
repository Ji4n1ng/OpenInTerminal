#!/usr/bin/env python3
"""Run production migration/reset functions against disposable preference domains."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
constants = (root / 'OpenInTerminalCore/Constants.swift').read_text()
defaults = (root / 'OpenInTerminalCore/Defaults.swift').read_text().split('public class DefaultsKeys')[0]
tests = r'''
let names = (0..<4).map { "test.OpenInTerminal.migration.\(UUID().uuidString).\($0)" }
let stores = names.map { UserDefaults(suiteName: $0)! }
defer { for (name, store) in zip(names, stores) { store.removePersistentDomain(forName: name) } }
let destination = stores[0]
let sources = Array(names.dropFirst())
stores[1].set("Ghostty", forKey: "DefaultTerminal")
stores[1].set("not a preference", forKey: "UnknownKey")
stores[2].set("iTerm", forKey: "DefaultTerminal")
stores[2].set("Zed", forKey: "DefaultEditor")
stores[2].set("previous", forKey: "NeovimCommand")
stores[3].set(true, forKey: "HideStatusItem")
stores[3].set("legacy", forKey: "KittyCommand")
destination.set(false, forKey: "HideStatusItem")
destination.set("", forKey: "DefaultEditor")
destination.register(defaults: ["DefaultTerminal": "Terminal"])
func migrate(_ process: String? = Constants.Id.MainApp) {
    migrateLegacyDefaultsIfNeeded(to: destination, domainName: names[0],
                                 processIdentifier: process, sourceDomains: sources)
}
for process in [nil, Constants.Id.MainApp + ".OpenInTerminalFinderExtension", Constants.Id.OpenInTerminalLite] {
    migrate(process)
    assert(destination.object(forKey: defaultsMigrationVersionKey) == nil)
    assert(destination.persistentDomain(forName: names[0])?["DefaultTerminal"] == nil)
}
// Repair the old completion marker, including one written by Finder first.
destination.set(1, forKey: defaultsMigrationVersionKey)
migrate()
assert(destination.string(forKey: "DefaultTerminal") == "Ghostty")
assert(destination.string(forKey: "DefaultEditor") == "")
assert(destination.bool(forKey: "HideStatusItem") == false)
assert(destination.string(forKey: "KittyCommand") == "legacy")
assert(destination.string(forKey: "NeovimCommand") == "previous")
assert(destination.object(forKey: "UnknownKey") == nil)
assert(destination.integer(forKey: defaultsMigrationVersionKey) == 2)
stores[1].set("changed", forKey: "DefaultTerminal")
migrate()
assert(destination.string(forKey: "DefaultTerminal") == "Ghostty")
let reopened = UserDefaults(suiteName: names[0])!
assert(reopened.string(forKey: "DefaultTerminal") == "Ghostty")
// A reset clears migration keys from all stores without deleting unrelated data.
resetDefaults(in: destination, domainName: names[0], sourceDomains: sources)
assert(stores[1].string(forKey: "UnknownKey") == "not a preference")
for store in stores {
    assert(store.integer(forKey: defaultsMigrationVersionKey) == 2)
}
for (name, store) in zip(names, stores) {
    let values = store.persistentDomain(forName: name) ?? [:]
    assert(values["DefaultTerminal"] == nil)
    assert(values["DefaultEditor"] == nil)
    assert(values["KittyCommand"] == nil)
}
// Force another migration and include the destination among the sources.
destination.removeObject(forKey: defaultsMigrationVersionKey)
migrateLegacyDefaultsIfNeeded(to: destination, domainName: names[0],
                             processIdentifier: Constants.Id.MainApp, sourceDomains: names)
assert(destination.persistentDomain(forName: names[0])?["KittyCommand"] == nil)
print("PASS: host-only migration, v1 repair, source priority, destination preservation, persistence, idempotence, reset, self-source exclusion")
'''
with tempfile.TemporaryDirectory(prefix='oit-migration-') as temporary:
    path = Path(temporary) / 'main.swift'
    path.write_text(constants + '\n' + defaults + '\n' + tests)
    subprocess.run(['xcrun', 'swift', '-module-cache-path', temporary + '/cache', str(path)], check=True)
