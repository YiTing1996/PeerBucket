//
//  Printer.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2023/12/4.
//

import UIKit

class Log: NSObject {
    
    /// Warning
    static func w<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        let prefix = "💛 WARN "
        let log: String = prefix + filename + "[\(line)]: \(method)" + "\n\(message)\n"
        print(log)
    }
    
    /// Verbose
    static func v<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        let prefix = "💜 VERBOSE "
        let log: String = prefix + filename + "[\(line)]: \(method)" + "\n\(message)\n"
        print(log)
    }
    
    /// Error
    static func e<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        let prefix = "❤️ ERROR "
        let log: String = prefix + filename + "[\(line)]: \(method)" + "\n\(message)\n"
        print(log)
    }
}
