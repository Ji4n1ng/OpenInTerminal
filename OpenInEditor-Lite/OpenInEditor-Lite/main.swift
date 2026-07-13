//
//  main.swift
//  OpenInEditor-Lite
//
//  Created by Jianing Wang on 2019/6/25.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import AppKit
import Foundation
import OpenInTerminalCore

do {

    if let editorName = DefaultsManager.shared.liteDefaultEditor {
        let editor = App(name: editorName, type: .editor)
        try editor.openOutsideSandbox()
    } else {
        guard let selectedEditor = pickEditor() else {
            throw OITLError.cannotGetEditor
        }
        DefaultsManager.shared.liteDefaultEditor = selectedEditor.name
        try selectedEditor.openOutsideSandbox()
    }

} catch {
    logw(error.localizedDescription)
}

// MARK: - Editor Picker

/// Presents an elegant, compact dialog for choosing the default editor.
///
/// Instead of stacking one push button per editor — which grows unwieldy as
/// more editors are supported — every editor is offered in a single popup
/// menu. Editors actually installed on this Mac are listed first, each showing
/// its real on-disk icon; the remaining supported editors follow below a
/// separator, dimmed and carrying their bundled icons. This keeps the dialog the
/// same small size no matter how many editors are supported.
func pickEditor() -> App? {
    let installedNames = FinderManager.shared.getAllInstalledApps()
    let installed = SupportedApps.editors.filter { installedNames.contains($0.name) }
    let notInstalled = SupportedApps.editors.filter { !installedNames.contains($0.name) }

    let alert = NSAlert()
    alert.messageText = NSLocalizedString("alert.pick_editor_title", comment: "Open In?")
    alert.informativeText = NSLocalizedString("alert.pick_editor_description", comment: "Please select one of the following editors as the default editor to open.")

    // A single popup keeps the dialog compact no matter how many editors exist.
    let popup = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 280, height: 25))
    let menu = popup.menu!
    var firstSelectable: NSMenuItem?

    for app in installed {
        let item = app.menuItem(installed: true)
        menu.addItem(item)
        if firstSelectable == nil { firstSelectable = item }
    }
    if !installed.isEmpty && !notInstalled.isEmpty {
        menu.addItem(.separator())
    }
    for app in notInstalled {
        let item = app.menuItem(installed: false)
        menu.addItem(item)
        if firstSelectable == nil { firstSelectable = item }
    }
    if let firstSelectable = firstSelectable {
        popup.select(firstSelectable)
    }
    alert.accessoryView = popup

    let okString = NSLocalizedString("general.ok", comment: "OK")
    let cancelString = NSLocalizedString("general.cancel", comment: "Cancel")
    alert.addButton(withTitle: okString)
    // Add button and avoid the focus ring
    alert.addButton(withTitle: cancelString).refusesFirstResponder = true

    // Open with the popup focused rather than a highlighted push button.
    alert.window.initialFirstResponder = popup

    guard alert.runModal() == .alertFirstButtonReturn else {
        return nil
    }
    return popup.selectedItem?.representedObject as? App
}

// MARK: - App Menu Item

private extension SupportedApps {

    /// A popup menu item representing this app. Installed apps use their real
    /// on-disk icon and a normal label; not-installed apps use the icon bundled
    /// in `Icons.xcassets` and a dimmed label.
    func menuItem(installed: Bool) -> NSMenuItem {
        let item = NSMenuItem(title: name, action: nil, keyEquivalent: "")
        item.representedObject = app

        let icon = installed ? (diskIcon ?? bundledIcon) : (bundledIcon ?? diskIcon)
        if let icon = icon {
            icon.size = NSSize(width: 18, height: 18)
            item.image = icon
        }

        if !installed {
            item.attributedTitle = NSAttributedString(
                string: name,
                attributes: [.foregroundColor: NSColor.secondaryLabelColor])
        }
        return item
    }

    /// The real icon of the copy installed on disk, if it can be located.
    var diskIcon: NSImage? {
        if !bundleId.isEmpty,
           let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            return NSWorkspace.shared.icon(forFile: url.path)
        }
        // Some supported apps ship without a stable bundle id; look them up by name.
        let byName = "/Applications/\(name).app"
        if FileManager.default.fileExists(atPath: byName) {
            return NSWorkspace.shared.icon(forFile: byName)
        }
        return nil
    }

    /// The icon bundled with the app (from `Icons.xcassets`), named after the app.
    var bundledIcon: NSImage? {
        return NSImage(named: name)
    }
}
