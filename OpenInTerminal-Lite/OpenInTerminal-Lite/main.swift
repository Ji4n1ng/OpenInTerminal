//
//  main.swift
//  OpenInTerminal-Lite
//
//  Created by Jianing Wang on 2019/4/19.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import AppKit
import Foundation
import OpenInTerminalCore

do {

    if let terminalName = DefaultsManager.shared.liteDefaultTerminal {
        let terminal = App(name: terminalName, type: .terminal)
        try terminal.openOutsideSandbox()
    } else {
        guard let selectedTerminal = pickTerminal() else {
            throw OITLError.cannotGetTerminal
        }
        DefaultsManager.shared.liteDefaultTerminal = selectedTerminal.name
        try selectedTerminal.openOutsideSandbox()
    }

} catch {
    logw(error.localizedDescription)
}

// MARK: - Terminal Picker

/// Presents an elegant, compact dialog for choosing the default terminal.
///
/// Instead of stacking one push button per terminal — which grows unwieldy as
/// more terminals are supported — every terminal is offered in a single popup
/// menu. Terminals actually installed on this Mac are listed first, each showing
/// its real on-disk icon; the remaining supported terminals follow below a
/// separator, dimmed and carrying their bundled icons. This keeps the dialog the
/// same small size no matter how many terminals are supported.
func pickTerminal() -> App? {
    let installedNames = FinderManager.shared.getAllInstalledApps()
    let installed = SupportedApps.terminals.filter { installedNames.contains($0.name) }
    let notInstalled = SupportedApps.terminals.filter { !installedNames.contains($0.name) }

    let alert = NSAlert()
    alert.messageText = NSLocalizedString("alert.pick_terminal_title", comment: "Open In?")
    alert.informativeText = NSLocalizedString("alert.pick_terminal_description", comment: "Please select one of the following terminals as the default terminal to open.")

    // A single popup keeps the dialog compact no matter how many terminals exist.
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
