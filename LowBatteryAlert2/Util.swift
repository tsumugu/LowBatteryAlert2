//
//  Util.swift
//  LowBatteryAlert2
//
//  Created by 山口紡 on 2021/04/01.
//

import Foundation

class Util {
    class func getBatteryState() -> [String?] {
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
}
