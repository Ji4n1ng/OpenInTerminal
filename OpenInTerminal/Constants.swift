//
//  Config.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/20.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import Foundation
import OpenInTerminalCore

struct Constants {
    
    struct Id {
        static let LauncherApp = "wang.jianing.app.OpenInTerminalHelper"

        /// Bundle identifier of the embedded Finder extension.
        ///
        /// Derived from the host app's own identifier rather than hardcoded:
        /// the extension target is named after the app, so a fork that changes
        /// `PRODUCT_BUNDLE_IDENTIFIER` would otherwise have `checkScripts()`
        /// install the AppleScripts into the *original* developer's
        /// `~/Library/Application Scripts/…` folder, while the extension looks
        /// for them under its own — and silently do nothing when clicked.
        static let FinderExtension: String = {
            let suffix = "OpenInTerminalFinderExtension"
            guard let appId = Bundle.main.bundleIdentifier else {
                return "wang.jianing.app.OpenInTerminal." + suffix
            }
            return appId + "." + suffix
        }()
        static let CustomAppCell = NSUserInterfaceItemIdentifier(rawValue: "customAppCell")
        static let CustomMenuCell = NSUserInterfaceItemIdentifier(rawValue: "customMenuCell")
        static let CustomInputViewController = "CustomInputViewController"
    }
    
    static let none = "None"
    
    struct Key {
        static let defaultTerminalShortcut = "OIT_DefaultTerminalShortcut"
        static let defaultEditorShortcut = "OIT_DefaultEditorShortcut"
        static let copyPathShortcut = "OIT_CopyPathShortcut"
        static let onlyActivateShortcutsInFinder = "OnlyActivateShortcutsInFinder"
    }
    
    static let PreferencesStoryboard = NSStoryboard(name: "Preferences", bundle: nil)
}

extension NSImage {
    
    enum AssetIdentifier: String {
        case StatusBarIcon
    }
    
    convenience init(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)!
    }
}

extension NSStoryboard {
    
    enum StoryboardIdentifier: String {
        case Preferences
    }
    
    convenience init(storyboardIdentifier: StoryboardIdentifier) {
        self.init(name: storyboardIdentifier.rawValue, bundle: nil)
    }
}
