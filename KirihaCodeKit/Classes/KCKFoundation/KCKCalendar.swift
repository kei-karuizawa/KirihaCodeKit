//
//  KCKCalendar.swift
//  Kiriha
//
//  Created by 河瀬雫 on 2022/11/15.
//

import Foundation

public struct KCKCalendar {
    
    public static var current: KCKCalendar = KCKCalendar()
    
    private var calendar: Calendar = Calendar.current
    
    public init() {
        self.calendar = Calendar.current
    }
    
    public init(calendar: Calendar) {
        self.calendar = calendar
    }
    
    public func day(date: KCKDate) -> Int {
        var dateComponents: DateComponents = DateComponents.init()
        dateComponents = self.calendar.dateComponents([.day], from: date.toDate())
        return dateComponents.day!
    }
    
    public func month(date: KCKDate) -> Int {
        var dateComponents: DateComponents = DateComponents.init()
        dateComponents = self.calendar.dateComponents([.month], from: date.toDate())
        return dateComponents.month!
    }
    
    // Week 的范围是 1~7，其中 1 代表星期天，2 代表星期一。
    public func week(date: KCKDate) -> Int {
        var dateComponents: DateComponents = DateComponents.init()
        dateComponents = self.calendar.dateComponents([.weekday], from: date.toDate())
        return dateComponents.weekday!
    }
    
    public func date(byAdding: Calendar.Component, value: Int, to: KCKDate) -> KCKDate {
        let date: Date = self.calendar.date(byAdding: byAdding, value: value, to: to.toDate())!
        return KCKDate.init(date: date)
    }
}

extension KCKCalendar {
    
    // MARK: - 获取给定时间的月份的第一天。
    
    public func getFirstDateOfMonth(date: KCKDate) -> KCKDate {
        let dateComponents: DateComponents = self.calendar.dateComponents([.year, .month], from: date.toDate())
        let firstDateOfMonth: KCKDate = KCKDate(date: self.calendar.date(from: dateComponents)!)
        return firstDateOfMonth
    }
    
    // MARK: - 获取给定时间月份的最后一天。
    
    public func getLastDateOfMonth(date: KCKDate) -> KCKDate {
        var dateComponents: DateComponents = DateComponents.init()
        dateComponents.month = 1
        dateComponents.second = -1
        let lastDateOfMonth: KCKDate = KCKDate(date: self.calendar.date(byAdding: dateComponents, to: self.getFirstDateOfMonth(date: date).toDate())!)
        return lastDateOfMonth
    }
}
