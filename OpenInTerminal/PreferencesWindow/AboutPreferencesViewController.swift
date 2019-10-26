//
//  AboutPreferencesViewController.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/5/1.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa

class AboutPreferencesViewController: PreferencesViewController {

    @IBOutlet weak var versionLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let versionObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        versionLabel.stringValue = versionObject as? String ?? ""
    }
    
    @IBAction func githubButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://github.com/Ji4n1ng/OpenInTerminal") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func contactButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "mailto:contact@jianing.wang?subject=OpenInTerminal%20Feedback") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func twitterButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://twitter.com/Ji4n1ng") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func paypalButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://paypal.me/ji4n1ng") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func alipayButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://github.com/Ji4n1ng/OpenInTerminal/blob/master/Resources/screenshots/Alipay.jpg") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func weChatPayButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://github.com/Ji4n1ng/OpenInTerminal/blob/master/Resources/screenshots/WeChatPay.jpg") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func camji55ButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://github.com/Camji55") else { return }
        NSWorkspace.shared.open(url)   
    }
}

class LinkButton: NSButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func resetCursorRects() {
        addCursorRect(self.bounds, cursor: .pointingHand)
    }
}
