//
//  Date+Ext.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 10/12/25.
//

import Foundation

extension Date {
    func adding(days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        var components = DateComponents()
        components.day = days
        components.hour = hours
        components.minute = minutes
        components.second = seconds
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
}
