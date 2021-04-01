//
//  AppDelegate.swift
//  LowBatteryAlert2
//
//  Created by 山口紡 on 2021/03/28.
//

import Cocoa
import WebKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let batteryPercentItem = NSMenuItem()
    let chargeStatusItem = NSMenuItem()
    var mainWindow = NSPanel()
    var previewWindow = NSPanel()
    var fileSelectWindow = NSPanel()
    
    func doPolling() {
        let batteryState = Util.getBatteryState()
        batteryPercentItem.title = "バッテリー残量: "+batteryState[2]!+"%"
        chargeStatusItem.title = "電源: "+batteryState[0]!
        let batteryPercent:Int = Int(batteryState[2]!)!
        if (Util.checkLowPower(batteryPercent: batteryPercent, chargeType: batteryState[0]!)) {
            mainWindow.orderFrontRegardless()
        } else {
            mainWindow.orderOut(self)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.doPolling()
        }
    }
    
    func initWindows() {
        let mainScreen = NSScreen.deepest!
        mainWindow = AlertWindow.view(mainScreen: mainScreen, isPreview: false)
        previewWindow = AlertWindow.view(mainScreen: mainScreen, isPreview: true)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // ツールバーの常駐設定
        if let button = statusItem.button {
          let size = NSMakeSize(22, 22)
          let image = NSImage(named: "icon.png")
          image?.size = size
          button.image = image
        }
        statusItem.highlightMode = true
        
        // メニューの設定
        statusItem.menu = menu
        // 残量%
        batteryPercentItem.action = #selector(AppDelegate.void(_:))
        menu.addItem(batteryPercentItem)
        // 充電状況
        chargeStatusItem.action = #selector(AppDelegate.void(_:))
        menu.addItem(chargeStatusItem)
        //入れ子
        let menuForHTMLItem = NSMenuItem()
        menuForHTMLItem.title = "警告画面設定"
        let menuForHTML = NSMenu()
        menuForHTMLItem.submenu = menuForHTML
        menu.addItem(menuForHTMLItem)
          // 警告画面をプレビュー
          let previewFileItem = NSMenuItem()
          previewFileItem.title = "警告画面をプレビュー"
          previewFileItem.action = #selector(AppDelegate.openAlertWindow(_:))
          menuForHTML.addItem(previewFileItem)
          // HTMLを選択
          let fileSelectItem = NSMenuItem()
          fileSelectItem.title = "HTMLファイルを選択して警告画面に設定"
          fileSelectItem.action = #selector(AppDelegate.openFileSelectPanel(_:))
          menuForHTML.addItem(fileSelectItem)
          // 設定を初期化
          let settingsResetItem = NSMenuItem()
          settingsResetItem.title = "設定をリセット"
          settingsResetItem.action = #selector(AppDelegate.resetSettings(_:))
          menuForHTML.addItem(settingsResetItem)
        // 終了
        let quitItem = NSMenuItem()
        quitItem.title = "Quit"
        quitItem.action = #selector(AppDelegate.quit(_:))
        menu.addItem(quitItem)
        
        // 警告ウインドウの設定
        self.initWindows()
        
        doPolling()
        //mainWindow.orderFrontRegardless()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func openFileSelectPanel(_ sender: Any) {
        let openPanel :NSOpenPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = true
        openPanel.allowedFileTypes = ["html","htm"]
        openPanel.begin(completionHandler: { (num) -> Void in
            if num == NSApplication.ModalResponse.OK {
                for fileURL in openPanel.urls {
                    // fileURLを保存する
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(fileURL.absoluteString, forKey: "filePath")
                    self.initWindows()
                }
            }
       })
    }
    
    @objc func openAlertWindow(_ sender: Any) {
        previewWindow.orderFrontRegardless()
    }
    
    @objc func resetSettings(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "filePath")
        self.initWindows()
        
    }
    
    @objc func quit(_ sender: Any){
        NSApplication.shared.terminate(self)
    }
    
    @objc func void(_ sender: Any){
       
    }

}

