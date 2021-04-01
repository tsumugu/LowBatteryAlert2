//
//  AlertWindow.swift
//  LowBatteryAlert2
//
//  Created by 山口紡 on 2021/04/01.
//

import Cocoa
import Foundation

class AlertWindow {
    class func view(mainScreen:NSScreen)->NSPanel {
        var mainWindow = NSPanel()
        mainWindow = NSPanel(contentRect: mainScreen.frame, styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: true)
        mainWindow.level = .mainMenu
        var mainView = NSView()
        mainWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        mainWindow.center()
        mainView = NSView(frame: mainScreen.frame)
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = NSColor.black.cgColor
        mainWindow.contentView!.addSubview(mainView)
        
        // 警告ウインドウの内容設定
        let cell = NSTableCellView()
        cell.frame = mainScreen.frame
        let tf = TF.mainViewTf(cell: cell)
        cell.addSubview(tf)
        mainView.addSubview(cell)
        return mainWindow
    }
}
