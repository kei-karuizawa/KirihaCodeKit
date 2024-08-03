//
//  KCKCalendarDateCell.swift
//  Kiriha
//
//  Created by Grass Plainson on 2021/3/8.
//

import Foundation
import UIKit

class KCKCalendarDateCell: UICollectionViewCell {
    
    var date: KCKDate!
    var calendarView: KCKCalendarView!
    var fillWithLastAndNextMonthDay: Bool = true  // 当月日期多余的位置是否填充上个月和下个月的日期，默认填充。
    
    var dateCellTinColor: UIColor?
    var otherDateCellColor: UIColor?
    var weekDateCellColor: UIColor?
    
    var handleTapDate: ((_ view: KCKCalendarView, _ cell: KCKCalendarDateButton) -> Void)?
    var viewForCellHandle: ((_ view: KCKCalendarView, _ cellItemSize: CGSize, _ date: KCKDate?) -> KCKUIView?)?
    var enableSelectDateHandler: ((_ view: KCKCalendarView, _ date: KCKDate, _ cell: KCKCalendarDateButton) -> Bool)?
    
    //var enableDateRange: (start: String, end: String)? = nil
    
    private var currentDateArray: [KCKDate?] = [KCKDate?](repeating: KCKDate(), count: 49)
            
    private var dateView: UIView!
    
    private var prefixSelectedButton: KCKUIButton?
    
    // MARK: - Init。
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - 更新某月的日期数据，让该月的每一天各归其位。
    
    private func update() {
        let calendar: KCKCalendar = KCKCalendar.current
        let firstDateOfMonth: KCKDate = calendar.getFirstDateOfMonth(date: self.date)
        
        // - 如果需要填充上个月和下个月的日期，需要提前计算好上个月的最后一天以避免在下面的循环中重复计算。
        
        var lastDateOfLastMonth: KCKDate = KCKDate()  // 上个月的最后一天。
        if self.fillWithLastAndNextMonthDay {
            let day: KCKDate = calendar.date(byAdding: .day, value: -1, to: firstDateOfMonth)
            lastDateOfLastMonth = day
        }
        
        var dayNum: Int = 1
        var retainDays: Int = self.transformWeekday(day: firstDateOfMonth.week)  // 准备填入的上个月的总天数。
        for index in 7..<49 {  // 数组固定 49 个元素，前 7 个元素被星期日～星期六的字符串占据。
            if dayNum > lastDateOfLastMonth.day {
                let date: KCKDate = KCKCalendar.current.date(
                    byAdding: .day,
                    value: dayNum - 1,
                    to: firstDateOfMonth
                )
                date.mark = String(date.day)
                self.currentDateArray[index] = date
                dayNum += 1
            } else if index - 7 < 6 &&
                      index - 7 < self.transformWeekday(day: firstDateOfMonth.week)
            {
                let date: KCKDate = KCKCalendar.current.date(
                    byAdding: .day,
                    value: -retainDays,
                    to: firstDateOfMonth
                )
                date.mark = String(date.day)
                self.currentDateArray[index] = date
                retainDays -= 1
            } else {
                let date: KCKDate = KCKCalendar.current.date(
                    byAdding: .day,
                    value: dayNum - 1,
                    to: firstDateOfMonth
                )
                date.mark = String(date.day)
                self.currentDateArray[index] = date
                dayNum += 1
            }
        }
    }
    
    // MARK: - 转化星期计数。
    
    private func transformWeekday(day: Int) -> Int {
        // 正常情况下，使用系统默认的 api，weeday 的范围是 1~7，
        // 其中 1 代表星期天，2 代表星期一。
        // 为了直观，该方法将星期天设置为 0。
        return day - 1
    }
    
    // MARK: - 刷新数据，填入数据。
    
    func refreshDateView(beginTime: String?, endTime: String?) {
        self.update()

        self.dateView?.removeFromSuperview()
        self.dateView = KCKUIView()
        self.dateView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.contentView.frame.width,
            height: self.contentView.frame.height
        )
        self.contentView.addSubview(self.dateView)
        for i in 0...48 {
            let dateButton: KCKCalendarDateButton = KCKCalendarDateButton()
            dateButton.backgroundColor = .white
            dateButton.titleLabel?.textAlignment = .center
            dateButton.isSelected = false
            switch i {
            case 0:
                self.currentDateArray[i] = nil
                dateButton.setTitle("日", for: .normal)
                dateButton.tag = 100
            case 1:
                self.currentDateArray[i] = nil
                dateButton.setTitle("一", for: .normal)
                dateButton.tag = 101
            case 2:
                self.currentDateArray[i] = nil
                dateButton.setTitle("二", for: .normal)
                dateButton.tag = 102
            case 3:
                self.currentDateArray[i] = nil
                dateButton.setTitle("三", for: .normal)
                dateButton.tag = 103
            case 4:
                self.currentDateArray[i] = nil
                dateButton.setTitle("四", for: .normal)
                dateButton.tag = 104
            case 5:
                self.currentDateArray[i] = nil
                dateButton.setTitle("五", for: .normal)
                dateButton.tag = 105
            case 6:
                self.currentDateArray[i] = nil
                dateButton.setTitle("六", for: .normal)
                dateButton.tag = 106
            default:
                dateButton.date = self.currentDateArray[i]
                dateButton.tag = 100 + i
            }
            let itemSizeWidth: CGFloat = self.dateView.frame.width / 7
            let itemSizeHeight: CGFloat = itemSizeWidth
            dateButton.frame = CGRect(
                x: CGFloat(i % 7) * itemSizeWidth,
                y: CGFloat(i / 7) * itemSizeHeight,
                width: itemSizeWidth,
                height: itemSizeHeight
            )
            
            if dateButton.date != nil {
                dateButton.setTitle(dateButton.date!.mark, for: .normal)
                dateButton.addTarget(
                    self,
                    action: #selector(self.handleTapDateButton(sender:)),
                    for: .touchUpInside
                )
                
                if let handle = self.viewForCellHandle {
                    dateButton.customView(view: handle(self.calendarView, CGSize(width: itemSizeWidth, height: itemSizeHeight), dateButton.date))
                }
                
//                self.enableButtonUI(range: self.enableDateRange, dateButton: dateButton)
//
//                self.rangeButtonUI(
//                    beginTime: beginTime,
//                    endTime: endTime,
//                    dateButton: dateButton
//                )
            } else {
                dateButton.setTitleColor(self.weekDateCellColor, for: .normal)
                
                if let handle = self.viewForCellHandle {
                    dateButton.customView(view: handle(self.calendarView, CGSize(width: itemSizeWidth, height: itemSizeHeight), nil))
                }
            }
            
            self.dateView.addSubview(dateButton)
        }
    }
    
    func beginRefreshRangeButtonUI(
        beginTime: String?,
        endTime: String?
    ) {
        for i in 7...48 {
            let button: KCKCalendarDateButton = self
                .dateView
                .viewWithTag(100 + i) as! KCKCalendarDateButton
            self.rangeButtonUI(beginTime: beginTime, endTime: endTime, dateButton: button)
        }
    }
    
    // 控制日期按钮的选中状态。
    private func rangeButtonUI(
        beginTime: String?,
        endTime: String?,
        dateButton: KCKCalendarDateButton
    ) {
        // 开始和结束日期都没选，保持原样。
        if beginTime == nil && endTime == nil {
        
        // 只选了开始日期，那么开始日期对应的日期按钮选中。
        } else if beginTime != nil && endTime == nil {
            if dateButton.date!.toString() == beginTime! {
//                dateButton.setTitleColor(.white, for: .normal)
//                dateButton.backgroundColor = UIColor.kiriha_colorWithHexString("#3951C4")
                dateButton.selectStatus = .left
                dateButton.isSelected = true
            }
            
        // 开始日期和结束日期都选了，那么此时有个范围选择。
        } else if beginTime != nil && endTime != nil {
            let dateString: String = dateButton.date!.toString()
            
            if dateString == beginTime! {
                dateButton.selectStatus = .left
                dateButton.isSelected = true
            }
            if dateString == endTime! {
                dateButton.selectStatus = .right
                dateButton.isSelected = true
            }
            
//            if dateString == beginTime! || dateString == endTime! {
//                dateButton.setTitleColor(.white, for: .normal)
//                dateButton.backgroundColor = UIColor.kiriha_colorWithHexString("#3951C4")
//                dateButton.isSelected = true
//            }
            
            // 不在范围选择之内。
            if dateString < beginTime! {
                dateButton.selectStatus = .none
            // 范围选择。
            } else if dateString > beginTime! && dateString < endTime! {
//                dateButton.backgroundColor = UIColor.kiriha_colorWithHexString(
//                    "#3951C4",
//                    alpha: 0.2
//                )
//                dateButton.setTitleColor(.white, for: .normal)
                dateButton.selectStatus = .range
                
            // 不在范围选择之内。
            } else if dateString > endTime! {
                
            }
            
        // 只选了结束日期，开始日期没选（不可能）。
        } else if beginTime == nil && endTime != nil {
            
        }
    }
    
    func beginRefreshEnableButtonUI(range: (start: String, end: String)?) {
        for i in 7...48 {
            let button: KCKCalendarDateButton = self
                .dateView
                .viewWithTag(100 + i) as! KCKCalendarDateButton
            self.enableButtonUI(range: range, dateButton: button)
        }
    }
    
    // 控制日期按钮是否允许点击。
    private func enableButtonUI(
        range: (start: String, end: String)?,
        dateButton: KCKCalendarDateButton
    ) {
        var enable: Bool = true
        
        if dateButton.date!.month != self.date.month {
            enable = false
        }
        
        if let rangeTuple: (start: String, end: String) = range {
            let dateString: String = dateButton.date!.toString()
            let startTime: String = rangeTuple.start
            let endTime: String = rangeTuple.end
            if dateString < startTime {
                enable = false
            } else if dateString > startTime && dateString < endTime {
                enable = true
            } else {
                enable = false
            }
        }
        
        let delegateEnable: Bool? = self.enableSelectDateHandler?(
            self.calendarView,
            dateButton.date!,
            dateButton
        )
        if delegateEnable != nil {
            enable = delegateEnable!
        }
        
        if enable {
            //dateButton.setTitleColor(self.dateCellTinColor, for: .normal)
        } else {
            //dateButton.setTitleColor(self.otherDateCellColor, for: .normal)
            dateButton.selectStatus = .unEnable
        }
        dateButton.isUserInteractionEnabled = enable
        dateButton.isEnabled = enable
    }
    
    // MARK: - 更改 UI 样式。
    
    private func setWeekButtonColor(color: UIColor?) {
        for i in 0...6 {
            let button: KCKCalendarDateButton = self
                .dateView
                .viewWithTag(100 + i) as! KCKCalendarDateButton
            button.setTitleColor(color, for: .normal)
        }
    }
    
    private func setDateButtonColor(color: UIColor?) {
        for i in 7...48 {
            let button: KCKCalendarDateButton = self
                .dateView
                .viewWithTag(100 + i) as! KCKCalendarDateButton
            if button.date!.month == self.date.month {
                button.setTitleColor(color, for: .normal)
            }
        }
    }
    
    private func setOtherDateButtonColor(color: UIColor?) {
        for i in 7...48 {
            let button: KCKCalendarDateButton = self
                .dateView
                .viewWithTag(100 + i) as! KCKCalendarDateButton
            if button.date!.month != self.date.month {
                button.setTitleColor(color, for: .normal)
            }
        }
    }
}

// MARK: - KCKCalendarDateCell.

extension KCKCalendarDateCell {
    
    @objc func handleTapDateButton(sender: KCKCalendarDateButton) {
        sender.isSelected = !sender.isSelected
        self.handleTapDate?(self.calendarView, sender)
    }
}

// MARK: - KCKCalendarDateButton.

public class KCKCalendarDateButton: KCKUIButton {
    
    enum SelectStatus {
        case none
        case left
        case right
        case range
        case unEnable
    }
    
    public var date: KCKDate?
    
    var selectStatus: KCKCalendarDateButton.SelectStatus = .range {
        willSet(newValue) {
            switch newValue {
            case .none:
                self.leftView.backgroundColor = .white
                self.rightView.backgroundColor = .white
                self.mainButton.backgroundColor = .white
                self.mainButton.setTitleColor(.black, for: .normal)
            case .left:
                self.leftView.backgroundColor = .white
                self.rightView.backgroundColor = UIColor.kiriha_colorWithHexString(
                    "#3951C4",
                    alpha: 0.2
                )
                self.mainButton.backgroundColor = UIColor.kiriha_colorWithHexString("#3951C4")
                self.mainButton.setTitleColor(.white, for: .normal)
            case .right:
                self.leftView.backgroundColor = UIColor.kiriha_colorWithHexString(
                    "#3951C4",
                    alpha: 0.2
                )
                self.rightView.backgroundColor = .white
                self.mainButton.backgroundColor = UIColor.kiriha_colorWithHexString("#3951C4")
                self.mainButton.setTitleColor(.white, for: .normal)
            case .range:
                self.leftView.backgroundColor = UIColor.kiriha_colorWithHexString(
                    "#3951C4",
                    alpha: 0.2
                )
                self.rightView.backgroundColor = UIColor.kiriha_colorWithHexString(
                    "#3951C4",
                    alpha: 0.2
                )
                self.mainButton.backgroundColor = UIColor.kiriha_colorWithHexString(
                    "#3951C4",
                    alpha: 0.2
                )
                self.mainButton.setTitleColor(.black, for: .normal)
            case .unEnable:
                self.leftView.backgroundColor = .white
                self.rightView.backgroundColor = .white
                self.mainButton.backgroundColor = .white
                self.mainButton.setTitleColor(.gray, for: .normal)
            }
        }
    }
    
    private var mainButton: KCKUIButton = {
        let button: KCKUIButton = KCKUIButton()
        button.titleLabel?.textAlignment = .center
        button.isUserInteractionEnabled = false
        button.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private var leftView: KCKUIView = {
        let view: KCKUIView = KCKUIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var rightView: KCKUIView = {
        let view: KCKUIView = KCKUIView()
        view.backgroundColor = .white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.mainButton)
        self.mainButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        self.addSubview(self.leftView)
        self.leftView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(self.mainButton.snp.left)
            make.top.bottom.equalTo(self.mainButton)
        }
        
        self.addSubview(self.rightView)
        self.rightView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.mainButton)
            make.left.equalTo(self.mainButton.snp.right)
            make.right.equalToSuperview()
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle("", for: state)
        self.mainButton.setTitle(title, for: state)
    }
    
    fileprivate func customView(view: KCKUIView?) {
        if view == nil {
            return
        }
        self.setTitle(nil, for: .normal)
        let backgroundView: KCKUIView = KCKUIView()
        backgroundView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.frame.width,
            height: self.frame.height
        )
        backgroundView.isUserInteractionEnabled = false
        self.addSubview(backgroundView)
        view!.frame = CGRect(
            x: 0,
            y: 0,
            width: backgroundView.frame.width,
            height: backgroundView.frame.height
        )
        view!.isUserInteractionEnabled = false
        backgroundView.addSubview(view!)
    }
    
}
