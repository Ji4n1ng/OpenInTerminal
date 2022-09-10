//
//  SupportedApps.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2020/12/5.
//  Copyright © 2020 Jianing Wang. All rights reserved.
//

import Foundation

public enum SupportedApps: String, CaseIterable {
    
    // MARK: - Terminals
    case terminal = "Terminal"
    case iTerm = "iTerm"
    case hyper = "Hyper"
    case alacritty = "Alacritty"
    case kitty = "kitty"
    case wezterm = "WezTerm"
    case tabby = "Tabby"
    
    // MARK: - Editors
    case textEdit = "TextEdit"
    case vscode = "Visual Studio Code"
    case atom = "Atom"
    case sublime = "Sublime Text"
    case vscodium = "VSCodium"
    case bbedit = "BBEdit"
    case vscodeInsiders = "Visual Studio Code - Insiders"
    case textMate = "TextMate"
    case cotEditor = "CotEditor"
    case macVim = "MacVim"
    case typora = "Typora"
    // JetBrains
    case appCode = "AppCode"
    case cLion = "CLion"
    case goLand = "GoLand"
    case intelliJIDEA = "IntelliJ IDEA"
    case phpStorm = "PhpStorm"
    case pyCharm = "PyCharm"
    case rubyMine = "RubyMine"
    case webStorm = "WebStorm"
    case androidstudio = "Android Studio"
    
    public var name: String {
        return self.rawValue
    }
    
    public var shortName: String {
        switch self {
        case .vscode: return "VSCode"
        case .sublime: return "Sublime"
        case .vscodeInsiders: return "VSCodeInsiders"
        case .intelliJIDEA: return "IntelliJ_IDEA"
        case .androidstudio: return "Android_Studio"
        default:
            return self.rawValue
        }
    }
    
    public var type: AppType {
        switch self {
		case .terminal, .iTerm, .hyper, .alacritty, .kitty, .wezterm, .tabby:
            return .terminal
        default:
            return .editor
        }
    }
    
    public static func isSupported(_ app: App) -> Bool {
        for sa in SupportedApps.allCases {
            if sa.name == app.name {
                return true
            }
        }
        return false
    }
    
    public static func `is`(_ app: App, is supported: SupportedApps) -> Bool {
        return app.name == supported.name
    }
    
    public static var terminals: [SupportedApps] {
        return SupportedApps.allCases.filter {
            $0.type == .terminal
        }
    }
    
    public static var editors: [SupportedApps] {
        return SupportedApps.allCases.filter {
            $0.type == .editor
        }
    }
    
    public var bundleId: String {
        switch self {
        // Terminals
        case .terminal: return "com.apple.Terminal"
        case .iTerm: return "com.googlecode.iterm2"
        case .hyper: return "co.zeit.hyper"
        case .alacritty: return "io.alacritty"
        case .kitty: return "net.kovidgoyal.kitty"
        case .wezterm: return "com.github.wez.wezterm"
        case .tabby: return "org.tabby"
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
        case .typora: return "abnerworks.Typora"
        case .appCode: return "com.jetbrains.appcode"
        case .cLion: return "com.jetbrains.clion"
        case .goLand: return "com.jetbrains.goland"
        case .intelliJIDEA: return "com.jetbrains.intellij"
        case .phpStorm: return "com.jetbrains.PhpStorm"
        case .pyCharm: return "com.jetbrains.pycharm"
        case .rubyMine: return "com.jetbrains.rubymine"
        case .webStorm: return "com.jetbrains.webstorm"
        case .androidstudio: return ""
        }
    }
    
    public var app: App {
        var app = App(name: self.name, type: self.type)
        app.bundleId = self.bundleId
        return app
    }
}
