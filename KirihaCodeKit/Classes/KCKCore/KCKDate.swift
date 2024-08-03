//
//  KCKDate.swift
//  Kiriha
//
//  Created by 河瀬雫 on 2021/12/16.
//

import Foundation

extension Date {
    
    /**
     获取接收者的秒级时间戳。
     */
    public func kiriha_timeStamp() -> String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        return "\(timeInterval)"
    }
    
    /**
     获取接收者的毫秒级时间戳。
     */
    public func kiriha_milliTimeStamp() -> String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval * 1000))
        return "\(millisecond)"
    }
    
}

extension Date {
    
    public enum KCKDateFormatter: String {
        case ym = "yyyy-MM"
        case ymd = "yyyy-MM-dd"
        case ymdHm = "yyyy-MM-dd HH:mm"
        case ymdHms = "yyyy-MM-dd HH:mm:ss"
        case md = "MM-dd"
        case dm = "dd-MM"
    }
    
    /**
     时间戳转日期字符串。返回的是毫秒级别的时间戳。
     */
    public static func kiriha_timeStampToDateString(timeStamp: Double, formatter: Date.KCKDateFormatter) -> String {
        let timesta: TimeInterval = timeStamp / 1000
        let aDateFormatter: DateFormatter = DateFormatter()
        aDateFormatter.dateFormat = formatter.rawValue
        let date: Date = Date(timeIntervalSince1970: timesta)
        return aDateFormatter.string(from: date)
    }
}

public class KCKDate: NSObject {

    static var today: KCKDate = KCKDate()
    
    public var dateFormatterString: String = "yyyy-MM-dd"
    
    private var date: Date!
    private var dateFormatter: KCKDateFormatter = KCKDateFormatter()
    private var calendar: KCKCalendar = KCKCalendar.current
    
    public var day: Int {
        return self.calendar.day(date: self)
    }
    
    public var month: Int {
        return self.calendar.month(date: self)
    }
    
    public var week: Int {
        return self.calendar.week(date: self)
    }
    
    public var mark: String?
    
    public override init() {
        super.init()
        
        self.date = Date()
        self.dateFormatter.dateFormat = self.dateFormatterString
    }
    
    public convenience init(date: Date) {
        self.init()
        
        self.date = date
    }
    
    public convenience init(date: Date, dateFormatterString: String) {
        self.init(date: date)
        
        self.dateFormatterString = dateFormatterString
    }
    
    public convenience init(date: Date, dateFormatterString: String, calendar: KCKCalendar) {
        self.init(date: date, dateFormatterString: dateFormatterString)
        
        self.calendar = calendar
    }
}

extension KCKDate {
    
    public func toDate() -> Date {
        return self.date
    }
    
    public func toString() -> String {
        return self.dateFormatter.string(from: self.date)
    }
}
