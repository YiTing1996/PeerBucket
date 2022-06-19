//
//  DateHelper.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    static var dateFormatter: DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
                
        return formatter
        
    }

    func distance(from date: Date,
                  only component: Calendar.Component,
                  calendar: Calendar = .current) -> Int {

        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)

        return days1 - days2
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        distance(from: date, only: component) == 0
    }
    
}
