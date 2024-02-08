//
//  Date+Extensions.swift
//  DemoFinances
//
//  Created by Sparrow on 2024-02-07.
//

import Foundation
// DateExtensions.swift

extension Date {
    func toString(format: String = Constant.Date.regular, style: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.dateFormat = format
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en")
        return formatter.string(from: self)
    }
    func adding(second: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: second, to: self)!
    }
    
    func adding(_ component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }
    
    func difference(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let components = calendar.dateComponents([component], from: date, to: self)
        switch component {
        case .year:
            return components.year ?? 0
        case .month:
            return components.month ?? 0
        case .weekOfMonth:
            return components.weekOfMonth ?? 0
        case .day:
            return components.day ?? 0
        case .hour:
            return components.hour ?? 0
        case .minute:
            return components.minute ?? 0
        case .second:
            return components.second ?? 0
        case .nanosecond:
            return components.nanosecond ?? 0
        default:
            return 0
        }
    }
    
    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        distance(from: date, only: component) == 0
    }
    
    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }
}
