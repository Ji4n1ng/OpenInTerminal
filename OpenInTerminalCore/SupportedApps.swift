//
//  SupportedApps.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2020/12/5.
//  Copyright © 2020 Jianing Wang. All rights reserved.
//

import Foundation

public enum SupportedApps: String {
    
    // MARK: - Terminals
    case terminal = "Terminal"
    case iTerm = "iTerm"
    case hyper = "Hyper"
    case alacritty = "Alacritty"
    case kitty = "kitty"
    
    // MARK: - Editors
    case textEdit = "TextEdit"
    case vscode = "VSCode"
    case atom = "Atom"
    case sublime = "Sublime"
    case vscodium = "VSCodium"
    case bbedit = "BBEdit"
    case vscodeInsiders = "VSCodeInsiders"
    case textMate = "TextMate"
    case cotEditor = "CotEditor"
    case macVim = "MacVim"
    // JetBrains
    case appCode = "AppCode"
    case cLion = "CLion"
    case goLand = "GoLand"
    case intelliJIDEA = "IntelliJ_IDEA"
    case phpStorm = "PhpStorm"
    case pyCharm = "PyCharm"
    case rubyMine = "RubyMine"
    case webStorm = "WebStorm"
    
    public var name: String {
        switch self {
        case .vscode: return "Visual Studio Code"
        case .sublime: return "Sublime Text"
        case .vscodeInsiders: return "Visual Studio Code - Insiders"
        case .intelliJIDEA: return "IntelliJ IDEA"
        default:
            return self.rawValue
        }
    }
    
    public var shortName: String {
        return self.rawValue
    }
    
    public var type: AppType {
        switch self {
        case .terminal, .iTerm, .hyper, .alacritty, .kitty:
            return .terminal
        default:
            return .editor
        }
    }
    
    public static func isSupported(app: App) -> Bool {
        guard let shortName = app.shortName else { return false }
        guard let _ = SupportedApps(rawValue: shortName) else { return false }
        return true
    }
    
    public static func `is`(_ app: App, is supported: SupportedApps) -> Bool {
        guard let shortName = app.shortName else { return false }
        guard let sa = SupportedApps(rawValue: shortName) else { return false }
        return sa == supported
    }
    
    public var bundleId: String {
        switch self {
        // Terminals
        case .terminal: return "com.apple.Terminal"
        case .iTerm: return "com.googlecode.iterm2"
        case .hyper: return "co.zeit.hyper"
        case .alacritty: return "io.alacritty"
        case .kitty: return "net.kovidgoyal.kitty"
        // Editors
        case .textEdit: return "com.apple.TextEdit"
        case .vscode: return "com.microsoft.VSCode"
        case .atom: return "com.github.atom"
        case .sublime: return "com.sublimetext.3"
        case .vscodium: return "com.visualstudio.code.oss"
        case .bbedit: return "com.barebones.bbedit"
        case .vscodeInsiders: return "com.microsoft.VSCodeInsiders"
        case .textMate: return "com.macromates.TextMate"
        case .cotEditor: return ""
        case .macVim: return "org.vim.MacVim"
        case .appCode: return "com.jetbrains.appcode"
        case .cLion: return "com.jetbrains.clion"
        case .goLand: return "com.jetbrains.goland"
        case .intelliJIDEA: return "com.jetbrains.intellij"
        case .phpStorm: return "com.jetbrains.PhpStorm"
        case .pyCharm: return "com.jetbrains.pycharm"
        case .rubyMine: return "com.jetbrains.rubymine"
        case .webStorm: return "com.jetbrains.webstorm"
        }
    }
    
    public var app: App {
        var app = App(name: self.name, type: self.type)
        app.shortName = self.shortName
        app.bundleId = self.bundleId
        return app
    }
}
