//
//  AlertWindow.swift
//  LowBatteryAlert2
//
//  Created by 山口紡 on 2021/04/01.
//

import Cocoa
import Foundation
import WebKit

class AlertWindow {
    class func view(mainScreen:NSScreen, isPreview: Bool)->NSPanel {
        var mainWindow = NSPanel()
        //プレビューモードだったら閉じるボタンを有効にする
        if (isPreview) {
            mainWindow = NSPanel(contentRect: mainScreen.frame, styleMask: [.titled, .nonactivatingPanel, .closable], backing: .buffered, defer: true)
        } else {
            mainWindow = NSPanel(contentRect: mainScreen.frame, styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: true)
        }
        mainWindow.level = .mainMenu
        var mainView = NSView()
        mainWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        mainWindow.center()
        mainView = NSView(frame: mainScreen.frame)
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = NSColor.black.cgColor
        mainWindow.contentView!.addSubview(mainView)
        
        let webView = WKWebView()
        webView.frame = mainScreen.frame
        mainView.addSubview(webView)
        
        // 警告ウインドウの内容設定
        var path: String? = Bundle.main.path(forResource: "index", ofType: "html")
        
        let userDefaults = UserDefaults.standard
        if var userLocalHTMLFilePath = userDefaults.string(forKey: "filePath") {
            userLocalHTMLFilePath = userLocalHTMLFilePath.replacingOccurrences(of: "file://", with: "")
            if (FileManager.default.fileExists(atPath: userLocalHTMLFilePath)) {
                path = userLocalHTMLFilePath
            }
        }
        let localHTMLUrl = URL(fileURLWithPath: path!, isDirectory: false)
        let request = URLRequest(url: localHTMLUrl)
        webView.load(request)
        
        return mainWindow
    }
}
