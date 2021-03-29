//
//  AppDelegate.swift
//  LowBatteryAlert2
//
//  Created by 山口紡 on 2021/03/28.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    
    var debugCallCount:Int = 0

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let batteryPercentItem = NSMenuItem()
    let chargeStatusItem = NSMenuItem()
    let quitItem = NSMenuItem()
    
    var mainWindow: NSPanel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 200, height: 200), styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: true)
    
    func getBatteryState() -> [String?] {
        let task = Process()
        let pipe = Pipe()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["-g", "batt"]
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        let batteryArray = output.components(separatedBy: ";")
        let source = output.components(separatedBy: "'")[1]
        let state = batteryArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces).capitalized
        let percent = batteryArray[0].components(separatedBy: "\t")[1].replacingOccurrences(of: "%", with: "")
        var remaining = batteryArray[2].components(separatedBy: " ")[1]
        if (remaining == "(no" || remaining == "not") {
            remaining = "Unknown"
        }
        return [source, state, percent, remaining]
    }
    
    func checkLowPower(batteryPercent:Int!, chargeType: String!) {
        if (batteryPercent <= 1 && chargeType == "Battery Power") {
            mainWindow.orderFrontRegardless()
        } else {
            mainWindow.orderOut(self)
        }
    }
    
    func doPolling() {
        let batteryState = getBatteryState()
        batteryPercentItem.title = "バッテリー残量: "+batteryState[2]!+"%"
        chargeStatusItem.title = "電源: "+batteryState[0]!
        let batteryPercent:Int = Int(batteryState[2]!)!
        self.checkLowPower(batteryPercent: batteryPercent, chargeType: batteryState[0]!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.doPolling()
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = self.statusItem.button {
          let size = NSMakeSize(22, 22)
          let image = NSImage(named: "icon.png")
          image?.size = size
          button.image = image
        }
        self.statusItem.highlightMode = true
        self.statusItem.menu = menu
        batteryPercentItem.action = #selector(AppDelegate.void(_:))
        menu.addItem(batteryPercentItem)
        chargeStatusItem.action = #selector(AppDelegate.void(_:))
        menu.addItem(chargeStatusItem)
        quitItem.title = "Quit"
        quitItem.action = #selector(AppDelegate.quit(_:))
        menu.addItem(quitItem)
        
        let mainScreen:NSScreen = NSScreen.deepest!
        mainWindow = NSPanel(contentRect: mainScreen.frame, styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: true)
        mainWindow.level = .mainMenu
        mainWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        mainWindow.center()
        
        let mainView = NSView(frame: mainScreen.frame)
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = NSColor.red.cgColor
        mainWindow.contentView!.addSubview(mainView)
        
        let cell = NSTableCellView()
        cell.frame = mainScreen.frame
        let tf = NSTextField()
        tf.frame = cell.frame
        tf.backgroundColor = NSColor.clear
        tf.textColor = NSColor.white
        tf.focusRingType = .none
        tf.wantsLayer = true
        tf.layer?.borderColor = NSColor.clear.cgColor
        tf.layer?.borderWidth = 1
        tf.isBordered = false
        tf.isEditable = false
        tf.font = NSFont.systemFont(ofSize: CGFloat(64))
        tf.stringValue = "【警告】バッテリー残量減少"
        tf.alignment = .center
        let stringHeight: CGFloat = tf.attributedStringValue.size().height
        let frame = tf.frame
        var titleRect:  NSRect = tf.cell!.titleRect(forBounds: frame)
        titleRect.size.height = stringHeight + ( stringHeight - (tf.font!.ascender + tf.font!.descender ) )
        titleRect.origin.y = frame.size.height / 2  - tf.lastBaselineOffsetFromBottom - tf.font!.xHeight / 2
        tf.frame = titleRect
        cell.addSubview(tf)
        mainView.addSubview(cell)
        
        doPolling()
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

