//
//  ViewController.swift
//  LowBatteryAlert2
//
//  Created by 山口紡 on 2021/03/28.
//

import Cocoa

class ViewController: NSViewController, NSUserNotificationCenterDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        // 以下の方法は一切のキー入力を受け付けなくなって詰むので却下
        let presOptions: NSApplication.PresentationOptions = .autoHideToolbar
        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions: presOptions]
        self.view.enterFullScreenMode(NSScreen.main!, withOptions:optionsDictionary)
        self.view.wantsLayer = true
        */
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

