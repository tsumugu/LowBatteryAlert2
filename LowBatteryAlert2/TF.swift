//
//  TF.swift
//  LowBatteryAlert2
//
//  Created by 山口紡 on 2021/04/01.
//

import Cocoa
import Foundation

class TF {
    class func mainViewTf(cell:NSTableCellView)->NSTextField {
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
}
