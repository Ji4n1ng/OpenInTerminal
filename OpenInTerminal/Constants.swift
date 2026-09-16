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
        /// Derived from the host app so `checkScripts()` installs AppleScripts
        /// into the folder the running extension actually looks in. A hardcoded
        /// id would write scripts to the original developer's folder when a fork
        /// changes `PRODUCT_BUNDLE_IDENTIFIER`.
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
