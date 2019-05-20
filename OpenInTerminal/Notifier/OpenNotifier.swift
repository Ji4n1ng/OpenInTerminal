//
//  OpenManager.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/19.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public class OpenNotifier: Notifier {

    public enum Notification: String {
        case openDefaultTerminal
        case openTerminal
        case openITerm
        case openHyper
        case openAlacritty
        
        case openDefaultEditor
        case openVSCode
        case openAtom
        case openSublime
        case openVSCodium
        
        case copyPathToClipboard
    }
    
}
