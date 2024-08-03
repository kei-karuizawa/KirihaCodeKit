//
//  KCKCalendarView.swift
//  Kiriha
//
//  Created by Grass Plainson on 2021/3/8.
//

import Foundation
import UIKit

public class KCKCalendarView: KCKUIView {
    
    // MARK: - Property.
    
    private var controlView: KCKUIView = {
        let view: KCKUIView = KCKUIView()
        return view
    }()
    private var dateDisplayLabel: KCKUILabel = {
        let label: KCKUILabel = KCKUILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    private var leftArrow: KCKUIButton = {
        let button: KCKUIButton = KCKUIButton()
        let bundle: Bundle = Bundle.kirihaBundle()
        let leftArrowImage: UIImage? = UIImage.kiriha_image(name: "arrow_left", in: bundle)
        button.setImage(leftArrowImage, for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    private var rightArrow: KCKUIButton = {
        let button: KCKUIButton = KCKUIButton()
        let bundle: Bundle = Bundle.kirihaBundle()
        let rightArrowImage: UIImage? = UIImage.kiriha_image(name: "arrow_right", in: bundle)
        button.setImage(rightArrowImage, for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    private var cancelButton: KCKUIButton = {
        let button: KCKUIButton = KCKUIButton()
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.kiriha_colorWithHexString("#3951C4"), for: .normal)
        button.layer.cornerRadius = 22.5
        button.layer.borderColor = UIColor.kiriha_colorWithHexString("#3951C4").cgColor
        button.layer.borderWidth = 1
        return button
    }()
    private var confirmButton: KCKUIButton = {
        let button: KCKUIButton = KCKUIButton()
        button.backgroundColor = UIColor.kiriha_colorWithHexString("#3951C4")
        button.setTitle("确认", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 22.5
        return button
    }()
    private var mainCollectionView: UICollectionView!
    
    public weak var delegate: KCKCalendarViewDelegate?
    
    /// 当月日期多余的位置是否填充上个月和下个月的日期，默认填充。
    public var fillWithLastAndNextMonthDay: Bool = true
    
    private var _allowManualScroll: Bool = true
    /// 是否允许手动滑动日历，如果为 `false`，则日历不允许左右滑动，只能通过 `controlView` 来控制日历月份切换。
    public var allowManualScroll: Bool {
        get {
            return self._allowManualScroll
        }
        set {
            self._allowManualScroll = newValue
            self.mainCollectionView.isScrollEnabled = newValue
        }
    }
    
    private var _allowControlView: Bool = true
    /// 是否打开日历切换控制视图，默认打开。
    public var allowControlView: Bool {
        get {
            return self._allowControlView
        }
        set {
            self._allowControlView = newValue
            self.layoutIfNeeded()
        }
    }
    
    /// 日历当中日期的 cell 字体颜色。
    public var dateCellTinColor: UIColor = .black
    
    /// 若 `fillWithLastAndNextMonthDay` 为 `true`，那么该值表示不属于当月的日期的 cell 的字体颜色。
    public var otherDateCellColor: UIColor = .lightGray
    
    /// 表示日历当中星期 X 的字体颜色。
    public var weekDateCellColor: UIColor = .lightGray
    
    public var controlTitleColor: UIColor = .gray
    
    public var controlArrowColor: UIColor = .gray
    
    public var enableMultipleSelection: Bool = true
    
    private var currentDate: KCKDate = KCKDate()
    private var currentIndex: Int = 12
    
    private var dateArray: [Int] = [-12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0]
    
    private var lastContentOffsetX: CGFloat = 0
    
    public var beginTime: String? = nil
    public var endTime: String? = nil
    public var beginDate: Date? {
        if self.beginTime == nil {
            return nil
        }
        let dateFormatter: KCKDateFormatter = KCKDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date: Date? = dateFormatter.date(from: self.beginTime!)
        return date
    }
    public var endDate: Date? {
        if self.endTime == nil {
            return nil
        }
        let dateFormatter: KCKDateFormatter = KCKDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date: Date? = dateFormatter.date(from: self.endTime!)
        return date
    }
    
    private var enableDateRange: (start: String, end: String)? = nil
    
    public var completionHandler: ((_ beginDate: Date?, _ endDate: Date?) -> Void)? = nil
    public var cancelHandler: (() -> Void)?
    
    // MARK: - Init.
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize(startDate: nil, endDate: nil)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.initialize(startDate: nil, endDate: nil)
    }
    
    public init(frame: CGRect, startDate: String?, endDate: String?) {
        super.init(frame: frame)
        self.initialize(startDate: startDate, endDate: endDate)
    }
    
    private func initialize(startDate: String?, endDate: String?) {
        self.beginTime = startDate
        self.endTime = endDate
        
        self.addSubview(self.controlView)
        self.controlView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(30)
        }
        
        self.leftArrow.addTarget(
            self,
            action: #selector(self.leftArrowHandle(sender:)),
            for: .touchUpInside
        )
        self.controlView.addSubview(self.leftArrow)
        self.leftArrow.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(39)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        self.rightArrow.addTarget(
            self,
            action: #selector(self.rightArrowHandle(sender:)),
            for: .touchUpInside
        )
        self.controlView.addSubview(self.rightArrow)
        self.rightArrow.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        self.controlView.addSubview(self.dateDisplayLabel)
        self.dateDisplayLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: self.frame.size.width, height: self.frame.size.width)
        //flowLayout.estimatedItemSize = CGSize(width: 100, height: 100)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        self.mainCollectionView = UICollectionView(
            frame: CGRect.zero,
            collectionViewLayout: flowLayout
        )
        self.mainCollectionView.backgroundColor = .white
        self.mainCollectionView.isScrollEnabled = false
        self.mainCollectionView.allowsSelection = true
        self.mainCollectionView.allowsMultipleSelection = false
        self.mainCollectionView.register(
            KCKCalendarDateCell.self,
            forCellWithReuseIdentifier: "DateCell"
        )
        self.mainCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
        self.mainCollectionView.isPagingEnabled = true
        self.mainCollectionView.showsVerticalScrollIndicator = false
        self.mainCollectionView.showsHorizontalScrollIndicator = false
        self.addSubview(self.mainCollectionView)
        self.mainCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.controlView.snp.bottom).offset(0)
            make.width.equalTo(self.frame.width)
            make.height.equalTo(self.snp.width)
        }
        
        self.cancelButton.addTarget(
            self,
            action: #selector(self.handleCancel),
            for: .touchUpInside
        )
        self.confirmButton.addTarget(
            self,
            action: #selector(self.handleConfirm)
            , for: .touchUpInside
        )
        self.addSubview(cancelButton)
        self.addSubview(confirmButton)
        self.cancelButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(self.mainCollectionView.snp.bottom).offset(5)
            make.height.equalTo(45)
            make.width.equalTo(self.confirmButton)
            make.right.equalTo(self.confirmButton.snp.left).offset(-15)
        }
        self.confirmButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(self.cancelButton)
            make.top.equalTo(self.cancelButton)
            make.height.equalTo(45)
        }
    }
    
    // MARK: - Layout subviews.
    
    public override func layoutSubviews() {
        self.mainCollectionView.scrollToItem(
            at: IndexPath(row: self.dateArray.count - 1, section: 0),
            at: .centeredHorizontally, animated: false
        )
        //self.lastContentOffsetX = self.frame.width * 9
    }
    
    // 根据当前日期推算几个月之前的日期。
    private func calculationDate(value: Int) -> KCKDate {
        let date: KCKDate = KCKCalendar.current.date(
            byAdding: .month,
            value: value,
            to: KCKDate()
        )
        return date
    }
    
    // MARK: - Left arrow and right arrow handle.
    
    @objc private func leftArrowHandle(sender: KCKUIButton) {
        //        if self.mainCollectionView.contentOffset.x == 0 {
        //            for _ in 0..<10 {
        //                self.monthCount += 1
        //                self.dateArray.insert(self.dateArray.first! - 1, at: 0)
        //                self.mainCollectionView.insertItems(at: [IndexPath.init(row: 0, section: 0)])
        //            }
        //            self.mainCollectionView.scrollToItem(
        //                at: IndexPath.init(row: 10, section: 0),
        //                at: .centeredHorizontally,
        //                animated: false
        //            )
        //        }
        guard self.currentIndex - 1 >= 0 else {
            return
        }
        self.currentIndex -= 1
        self.currentDate = KCKCalendar.current.date(
            byAdding: .month,
            value: -1,
            to: self.currentDate
        )
        self.mainCollectionView.scrollToItem(
            at: IndexPath(row: self.currentIndex, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
    }
    
    @objc private func rightArrowHandle(sender: KCKUIButton) {
        //        if self.mainCollectionView.contentOffset.x == CGFloat((self.monthCount - 1)) * self.frame.width {
        //            for _ in 0..<10 {
        //                self.monthCount += 1
        //                self.dateArray.insert(self.dateArray.last! + 1, at: self.dateArray.count)
        //                let indexPaths: [IndexPath] = [IndexPath(row: self.monthCount - 1, section: 0)]
        //                self.mainCollectionView.insertItems(at: indexPaths)
        //            }
        //            self.mainCollectionView.scrollToItem(
        //                at: IndexPath.init(row: self.monthCount - 11, section: 0),
        //                at: .centeredHorizontally,
        //                animated: false
        //            )
        //        }
        guard self.currentIndex + 1 >= 0 && self.currentIndex + 1 <= self.dateArray.count - 1 else {
            return
        }
        self.currentIndex += 1
        self.currentDate = KCKCalendar.current.date(
            byAdding: .month,
            value: +1,
            to: self.currentDate
        )
        self.mainCollectionView.scrollToItem(
            at: IndexPath(row: self.currentIndex, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
    }
    
    // 根据当前日期获取 collectionView 当中该月的 cell。
    private func getCurrentMonthCell() -> KCKCalendarDateCell? {
        let cells: [KCKCalendarDateCell] = self
            .mainCollectionView
            .visibleCells as! [KCKCalendarDateCell]
        for cell in cells {
            if cell.date.toString() == self.currentDate.toString() {
                return cell
            }
        }
        return nil
    }
    
    @objc private func handleCancel() {
        self.cancelHandler?()
    }
    
    @objc private func handleConfirm() {
        self.completionHandler?(self.beginDate, self.endDate)
    }
    
    // MARK: - Public.
    
    /// 可以使用这个方法让日历显示任何指定的日期的月份。
    //    public func jumpToDate(date: KCKDate) {
    //        self.currentDate = date
    //        self.dateDisplayLabel.text = String(self.currentDate.toString().prefix(7))
    //        self.mainCollectionView.reloadData()
    //        self.layoutIfNeeded()
    //        self.mainCollectionView.scrollToItem(
    //            at: IndexPath(row: self.currentIndex, section: 0),
    //            at: .centeredHorizontally,
    //            animated: false
    //        )
    //    }
    
    /// 可以使用这个方法让日历显示任何指定的月份，传入的参数必须为 `yyyy-MM` 形式，如 `2021-04`。
    //    public func jumpToMonth(month: String) {
    //        let dateString: String = "\(month)-01"
    //        let dateFormatter: KCKDateFormatter = KCKDateFormatter()
    //        dateFormatter.dateFormat = "yyyy-MM-dd"
    //        let date: Date? = dateFormatter.date(from: dateString)
    //        var shDate: KCKDate? = nil
    //        if date != nil {
    //            shDate = KCKDate(date: date!)
    //            self.jumpToDate(date: shDate!)
    //        }
    //    }
    
    /// 获取当前视图显示的月份。
    public func currentMonth() -> KCKDate {
        //        let contentOffSetX: Double = self.mainCollectionView.contentOffset.x
        //        let cellWidth: CGFloat = self.frame.width
        //        let cellIndex: Int = Int(contentOffSetX / cellWidth)
        //        kiriha_print("cellIndex: \(cellIndex)")
        //        let dateIndex: Int = self.dateArray[cellIndex]
        //        let date: KCKDate = KCKCalendar.current.date(
        //            byAdding: .month,
        //            value: dateIndex,
        //            to: KCKDate()
        //        )
        return self.currentDate
    }
    
    /// 刷新数据数据。
    public func reloadData() {
        self.mainCollectionView.reloadData()
    }
    
    /// 刷新样式和数据。
    public func refresh() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            let currentIndexPath: IndexPath = IndexPath(row: strongSelf.currentIndex, section: 0)
            let currentCell: KCKCalendarDateCell? = strongSelf
                .mainCollectionView
                .cellForItem(at: currentIndexPath) as? KCKCalendarDateCell
            currentCell?.refreshDateView(
                beginTime: strongSelf.beginTime,
                endTime: strongSelf.endTime
            )
            currentCell?.beginRefreshEnableButtonUI(range: strongSelf.enableDateRange)
            currentCell?.beginRefreshRangeButtonUI(
                beginTime: strongSelf.beginTime,
                endTime: strongSelf.endTime
            )
            let prefixIndexPath: IndexPath = IndexPath(row: strongSelf.currentIndex - 1, section: 0)
            let prefixCell: KCKCalendarDateCell? = strongSelf
                .mainCollectionView
                .cellForItem(at: prefixIndexPath) as? KCKCalendarDateCell
            let afterIndexPath: IndexPath = IndexPath(row: strongSelf.currentIndex + 1, section: 0)
            let afterCell: KCKCalendarDateCell? = strongSelf
                .mainCollectionView
                .cellForItem(at: afterIndexPath) as? KCKCalendarDateCell
            prefixCell?.refreshDateView(
                beginTime: strongSelf.beginTime,
                endTime: strongSelf.endTime
            )
            prefixCell?.beginRefreshEnableButtonUI(range: strongSelf.enableDateRange)
            prefixCell?.beginRefreshRangeButtonUI(
                beginTime: strongSelf.beginTime,
                endTime: strongSelf.endTime
            )
            afterCell?.refreshDateView(
                beginTime: strongSelf.beginTime,
                endTime: strongSelf.endTime
            )
            afterCell?.beginRefreshEnableButtonUI(range: strongSelf.enableDateRange)
            afterCell?.beginRefreshRangeButtonUI(
                beginTime: strongSelf.beginTime,
                endTime: strongSelf.endTime
            )
        }
    }
}

// MARK: - UICollectionViewDelegate.

extension KCKCalendarView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell: KCKCalendarDateCell? = collectionView
            .cellForItem(at: indexPath) as? KCKCalendarDateCell
        if cell != nil {
            self.dateDisplayLabel.text = String(cell!.date.toString().prefix(7))
        }
    }
    
}

extension KCKCalendarView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.dateDisplayLabel.text = String(self.currentMonth().toString().prefix(7))
        kiriha_print(String(self.currentMonth().toString().prefix(7)))
    }
}

// MARK: - UICollectionViewDataSource.

extension KCKCalendarView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dateArray.count
    }
    
    // 返回的元组开始表示允许选择范围的开始，结束表示允许选择范围的结束。
    private func judgeRange(selectedBeginDateString: String) -> (start: String, end: String) {
        let selectedBeginDate: KCKDate = KCKDate(date: self.beginDate!)
        let todayStr: String = KCKDate().toString()
        let prefix31: KCKDate = KCKCalendar.current.date(
            byAdding: .day,
            value: -31,
            to: selectedBeginDate
        )
        let prefix31Str: String = prefix31.toString()
        let after31: KCKDate = KCKCalendar.current.date(
            byAdding: .day,
            value: +31,
            to: selectedBeginDate
        )
        let after31Str: String = after31.toString()
        if after31Str > todayStr {
            return (start: prefix31Str, end: todayStr)
        } else {
            return (start: prefix31Str, end: after31Str)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: KCKCalendarDateCell = KCKCalendarDateCell()
        if self.allowManualScroll {
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DateCell",
                for: indexPath
            ) as! KCKCalendarDateCell
            let date: KCKDate = self.calculationDate(value: self.dateArray[indexPath.row])
            cell.date = date
            
        } else {
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DateCell",
                for: indexPath
            ) as! KCKCalendarDateCell
            cell.date = self.currentDate
        }
        
        cell.calendarView = self
        
        cell.handleTapDate = { [weak self] view, button in
            guard let strongSelf = self else { return }
            
            // 某个按钮被选中时：
            if button.isSelected {
                if button.date != nil {
                    // 若当前状态是：
                    // 初始状态，什么都没选。此时代表开始日期被选中。
                    if strongSelf.beginTime == nil && strongSelf.endTime == nil {
                        strongSelf.beginTime = button.date!.toString()
                        
                        // 点击了开始日期后，开始进行选择范围判断。
                        strongSelf.enableDateRange =
                            strongSelf.judgeRange(selectedBeginDateString: strongSelf.beginTime!)
                        
                    // 一开始就点击了一个日期，此时选的是结束日期。注意两者大小对比。
                    } else if strongSelf.beginTime != nil && strongSelf.endTime == nil {
                        let endString: String = button.date!.toString()
                        if strongSelf.beginTime! > endString {
                            strongSelf.endTime = strongSelf.beginTime
                            strongSelf.beginTime = endString
                        } else {
                            strongSelf.endTime = endString
                        }
                        
                    // 开始日期和结束日期都选了，此时原先选择的取消，重新开始范围选择。
                    } else if strongSelf.beginTime != nil && strongSelf.endTime != nil {
                        strongSelf.beginTime = button.date!.toString()
                        strongSelf.endTime = nil
                        
                        // 点击了开始日期后，开始进行选择范围判断。
                        strongSelf.enableDateRange =
                            strongSelf.judgeRange(selectedBeginDateString: strongSelf.beginTime!)
                        
                    // 开始日期没选，只选了结束日期（不可能）
                    } else if strongSelf.beginTime == nil && strongSelf.endTime != nil {
                        
                    }
                }
                
                strongSelf.delegate?.calendarView?(calendarView: view, didSelectCell: button)
                
            } else {
                // 某个按钮被反选时：
                if button.date != nil {
                    // 若当前状态是：
                    // 初始状态下不可能有反选情况（不可能）
                    if strongSelf.beginTime == nil && strongSelf.endTime == nil {
                    
                    // 之前开始日期选了， 那么此时反选的只可能是开始日期。
                    } else if strongSelf.beginTime != nil && strongSelf.endTime == nil {
                        strongSelf.beginTime = nil
                        
                    // 开始和结束日期都选了，那么此时反选的是结束日期，相当于只选了一个日期。
                    } else if strongSelf.beginTime != nil && strongSelf.endTime != nil {
                        strongSelf.beginTime = button.date!.toString()
                        strongSelf.endTime = nil
                        
                    // 开始日期没选，只选了结束日期（不可能）。
                    } else if strongSelf.beginTime == nil && strongSelf.endTime != nil {
                        
                    }
                }
                strongSelf.delegate?.calendarView?(calendarView: view, didDeSelectCell: button)
            }
            
            strongSelf.refresh()
        }

        // - delegate.
        
        if let delegate = self.delegate {
            cell.viewForCellHandle = { (view, size, date) in
                let view: KCKUIView? = delegate.calendarView?(
                    calendarView: view,
                    cellItemSize: size,
                    viewForCellAt: date
                )
                return view
            }
            
//            cell.enableSelectDateHandler = { view, date, cell in
//                let enable: Bool? = delegate.calendarView?(
//                    enableSelectDateIn: view,
//                    date: date,
//                    cell: cell
//                )
//                return enable ?? true
//            }
        }
        
        cell.dateCellTinColor = self.dateCellTinColor
        cell.otherDateCellColor = self.otherDateCellColor
        cell.weekDateCellColor = self.weekDateCellColor
        cell.refreshDateView(beginTime: self.beginTime, endTime: self.endTime)
        cell.beginRefreshEnableButtonUI(range: self.enableDateRange)
        cell.beginRefreshRangeButtonUI(beginTime: self.beginTime, endTime: self.endTime)
        return cell
    }
}

extension KCKCalendarView {
        
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffsetX = scrollView.contentOffset.x
//        if scrollView.contentOffset.x == 0 {
//            for _ in 0..<10 {
//                self.monthCount += 1
//                self.dateArray.insert(self.dateArray.first! - 1, at: 0)
//                self.mainCollectionView.insertItems(at: [IndexPath.init(row: 0, section: 0)])
//            }
//            self.mainCollectionView.scrollToItem(
//                at: IndexPath.init(row: 10, section: 0),
//                at: .centeredHorizontally,
//                animated: false
//            )
//        } else if scrollView.contentOffset.x == CGFloat((self.monthCount - 1)) * self.frame.width {
//            for _ in 0..<10 {
//                self.monthCount += 1
//                self.dateArray.insert(self.dateArray.last! + 1, at: self.dateArray.count)
//                let indexPaths: [IndexPath] = [IndexPath(row: self.monthCount - 1, section: 0)]
//                self.mainCollectionView.insertItems(at: indexPaths)
//            }
//            self.mainCollectionView.scrollToItem(
//                at: IndexPath.init(row: self.monthCount - 11, section: 0),
//                at: .centeredHorizontally,
//                animated: false
//            )
//        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.x < self.lastContentOffsetX {
            // 右滑，上一页
            guard self.currentIndex - 1 >= 0 else {
                return
            }
            self.currentIndex -= 1
            self.currentDate = KCKCalendar.current.date(
                byAdding: .month,
                value: -1,
                to: self.currentDate
            )
            
        } else if scrollView.contentOffset.x > self.lastContentOffsetX {
            // 左滑，下一页
            guard self.currentIndex + 1 >= 0 && self.currentIndex + 1 <= self.dateArray.count - 1 else {
                return
            }
            self.currentIndex += 1
            self.currentDate = KCKCalendar.current.date(
                byAdding: .month,
                value: +1,
                to: self.currentDate
            )
        }
    }
}
