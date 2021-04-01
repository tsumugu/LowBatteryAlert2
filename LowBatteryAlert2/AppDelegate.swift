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
          // 終了
        let quitItem = NSMenuItem()
        quitItem.title = "Quit"
        quitItem.action = #selector(AppDelegate.quit(_:))
        menu.addItem(quitItem)
        
        // 警告ウインドウの設定
        let mainScreen = NSScreen.deepest!
        mainWindow = AlertWindow.view(mainScreen: mainScreen)

        doPolling()
        //mainWindow.orderFrontRegardless()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func quit(_ sender: Any){
        NSApplication.shared.terminate(self)
    }
    @objc func void(_ sender: Any){
       
    }

}

