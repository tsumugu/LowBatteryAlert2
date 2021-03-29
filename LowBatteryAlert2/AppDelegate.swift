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
    //var beforeChargeStatus:String = "Unknown"
    
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
        // 電源供給源("Battery Power"/"AC Power"), 充電状況("Discharging"/"Ac Attached"), 充電残量("n%"), 残り充電時間("H:m")
        return [source, state, percent, remaining]
    }
    
    func checkLowPower(batteryPercent:Int!, chargeType: String!) {
        if (batteryPercent <= 1 && chargeType == "Battery Power") {
            print("バッテリー駆動状態で充電が1%を切りました")
            mainWindow.orderFrontRegardless()
        } else {
            mainWindow.orderOut(self)
        }
    }
    
    func doPolling() {
        let batteryState = getBatteryState()
        /*
        let timestamp = NSDate().timeIntervalSince1970
        //debug
        var batteryState = ["Battery Power", "Discharging", "1", "Unknown"]
        if (debugCallCount>1) {
            batteryState = ["AC Power", "Ac Attached", "1", "Unknown"]
        }
        if (debugCallCount>10) {
            batteryState = ["AC Power", "Ac Attached", "2", "Unknown"]
        }
        if (debugCallCount>20) {
            batteryState = ["AC Power", "Ac Attached", "2", "Unknown"]
        }
        if (debugCallCount>30) {
            batteryState = ["Battery Power", "Discharging", "1", "Unknown"]
        }
        print(batteryState, debugCallCount)
        debugCallCount+=1
        //
        //print(timestamp, batteryState)
        batteryPercentItem.title = "バッテリー残量: "+batteryState[2]+"%"
        chargeStatusItem.title = "電源: "+batteryState[0]
        let batteryPercent:Int = Int(batteryState[2])!
        self.checkLowPower(batteryPercent: batteryPercent, chargeType: batteryState[0])
        */
        batteryPercentItem.title = "バッテリー残量: "+batteryState[2]!+"%"
        chargeStatusItem.title = "電源: "+batteryState[0]!
        let batteryPercent:Int = Int(batteryState[2]!)!
        self.checkLowPower(batteryPercent: batteryPercent, chargeType: batteryState[0]!)
        /*
        // 充電ステータスが変わったら
        if (beforeChargeStatus != "Unknown" && batteryState[0] != beforeChargeStatus) {
            //onChangeChargeStatusEvent(chargeType: batteryState[0])
            let batteryPercent:Int = Int(batteryState[2]!)!
            self.checkLowPower(batteryPercent: batteryPercent, chargeType: batteryState[0]!)
        }
        beforeChargeStatus = batteryState[0]!
        */
        //
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.doPolling()
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
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
        
        // windowの準備
        /*
        let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = mainStoryboard.instantiateController(withIdentifier: "MyWindowController") as? NSWindowController
        windowController?.showWindow(nil)
        let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = mainStoryboard.instantiateController(withIdentifier: "MyWindowController") as? NSWindowController
        let storyboardViewController = windowController?.contentViewController as! NSViewController
        */
        let mainScreen:NSScreen = NSScreen.deepest!
        /*
        let mainWindow = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 200, height: 200), styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: true)
        */
        mainWindow = NSPanel(contentRect: mainScreen.frame, styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: true)
        mainWindow.level = .mainMenu
        mainWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        mainWindow.center()
        
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

