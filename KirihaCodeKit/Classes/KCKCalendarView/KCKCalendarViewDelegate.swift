//
//  KCKCalendarViewDelegate.swift
//  Kiriha
//
//  Created by Grass Plainson on 2021/3/8.
//

import Foundation
import UIKit

@objc public protocol KCKCalendarViewDelegate {
    
    @objc optional func calendarView(itemSizeForCalendarView: KCKCalendarView) -> CGSize
    
    @objc optional func calendarView(
        calendarView: KCKCalendarView,
        didSelectCell cell: KCKCalendarDateButton
    )
    
    @objc optional func calendarView(
        calendarView: KCKCalendarView,
        didDeSelectCell cell: KCKCalendarDateButton
    )
    
    @objc optional func calendarView(
        calendarView: KCKCalendarView,
        cellItemSize: CGSize,
        viewForCellAt date: KCKDate?
    ) -> KCKUIView?
    
    @objc optional func calendarView(
        enableSelectDateIn calendarView: KCKCalendarView,
        date: KCKDate,
        cell: KCKCalendarDateButton
    ) -> Bool
}
