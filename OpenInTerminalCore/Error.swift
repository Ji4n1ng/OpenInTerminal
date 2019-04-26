//
//  Error.swift
//  cd2swiftTest
//
//  Created by Jianing Wang on 2019/4/10.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

enum OITError: Error {
    
    case cannotAccessFinder
    case cannotAccessTerminal
    case cannotAccessIterm
    case cannotAccessHyper
    case cannotAccessAlacritty
    case cannotAccessVSCode
    case cannotAccessAtom
    case cannotAccessSublime
    case wrongUrl
    
}

extension OITError : CustomStringConvertible {

    var description: String {

        switch self {
            
        case .cannotAccessFinder:
            return "Cannot access Finder, please check permissions."
        case .cannotAccessTerminal:
            return "Cannot access Terminal, please check permissions."
        case .cannotAccessIterm:
            return "Cannot access iTerm, please check permissions."
        case .cannotAccessHyper:
            return "Cannot access Hyper, please check permissions."
        case .cannotAccessAlacritty:
            return "Cannot access Alacritty, please check permissions."
        case .cannotAccessVSCode:
            return "Cannot access VS Code, please check permissions."
        case .cannotAccessAtom:
            return "Cannot access Atom, please check permissions."
        case .cannotAccessSublime:
            return "Cannot access Sublime, please check permissions."
        case .wrongUrl:
            return "Oops, got a wrong url"
        }
    }
}
