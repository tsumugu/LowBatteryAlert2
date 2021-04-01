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
    
    func mainViewTf(cell:NSTableCellView)->NSTextField {
        let tf = NSTextField()
        tf.frame = cell.frame
        tf.backgroundColor = NSColor.clear
        tf.textColor = NSColor.orange
        tf.focusRingType = .none
        tf.wantsLayer = true
        tf.layer?.borderColor = NSColor.clear.cgColor
        tf.layer?.borderWidth = 1
        tf.isBordered = false
        tf.isEditable = false
        tf.font = NSFont(name: "Hiragino Mincho ProN W6", size: CGFloat(64))
        //tf.font = NSFont.systemFont(ofSize: 64, weight: NSFont.Weight.heavy)
        tf.stringValue = "バッテリー残量低下"
        tf.alignment = .center
        let stringHeight: CGFloat = tf.attributedStringValue.size().height
        let frame = tf.frame
        var titleRect:  NSRect = tf.cell!.titleRect(forBounds: frame)
        titleRect.size.height = stringHeight + ( stringHeight - (tf.font!.ascender + tf.font!.descender ) )
        titleRect.origin.y = frame.size.height / 2  - tf.lastBaselineOffsetFromBottom - tf.font!.xHeight / 2
        tf.frame = titleRect
        return tf
    }
    
    func checkLowPower(batteryPercent:Int!, chargeType: String!) {
        if (batteryPercent <= 1 && chargeType == "Battery Power") {
            mainWindow.orderFrontRegardless()
        } else {
            mainWindow.orderOut(self)
        }
    }
    
    func doPolling() {
        let batteryState = Util.getBatteryState()
        batteryPercentItem.title = "バッテリー残量: "+batteryState[2]!+"%"
        chargeStatusItem.title = "電源: "+batteryState[0]!
        let batteryPercent:Int = Int(batteryState[2]!)!
        self.checkLowPower(batteryPercent: batteryPercent, chargeType: batteryState[0]!)
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
        var mainScreen = NSScreen()
        var mainView = NSView()
        mainScreen = NSScreen.deepest!
        mainWindow = NSPanel(contentRect: mainScreen.frame, styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: true)
        mainWindow.level = .mainMenu
        mainWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        mainWindow.center()
        mainView = NSView(frame: mainScreen.frame)
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = NSColor.black.cgColor
        mainWindow.contentView!.addSubview(mainView)
        
        // 警告ウインドウの内容設定
        let cell = NSTableCellView()
        cell.frame = mainScreen.frame
        let tf = self.mainViewTf(cell: cell)
        cell.addSubview(tf)
        mainView.addSubview(cell)

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

