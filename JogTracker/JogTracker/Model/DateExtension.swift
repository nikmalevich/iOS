//
//  DateExtension.swift
//  JogTracker
//
//  Created by Admin on 07/06/2020.
//  Copyright © 2020 nikmal. All rights reserved.
//

import Foundation

extension Date {
    var startOfWeek: Date? {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return calendar.date(byAdding: .day, value: 1, to: sunday)
    }

    var endOfWeek: Date? {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return calendar.date(byAdding: .day, value: 7, to: sunday)
    }
}
