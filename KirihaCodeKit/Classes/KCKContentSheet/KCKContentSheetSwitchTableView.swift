//
//  KCKContentSheetSwitchTableView.swift
//  Kiriha
//
//  Created by 河瀬雫 on 2022/1/11.
//

import Foundation

@objc public protocol KCKContentSheetSwitchTableViewDelegate {
    
    @objc optional func contentSheetSwitchTableView(_ contentSheetSwitchTableView: KCKContentSheetSwitchTableView, didSwitchButtonStatusIn index: Int, with isOn: Bool)
    
    @objc optional func contentSheetSwitchTableView(_ contentSheetSwitchTableView: KCKContentSheetSwitchTableView, canSwitchButtonIn index: Int) -> Bool
    
}

open class KCKContentSheetSwitchTableView: KCKContentSheetTableView {
        
    open weak var delegate: KCKContentSheetSwitchTableViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.style = .contentSwitch
        self.actionTitle = "保存"
        self.showCancelButton = true
        self.showTitleLabel = true
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setTableView() {
        super.setTableView()
        
        self.mainTableView.register(KCKContentSheetSwitchTableViewCell.self, forCellReuseIdentifier: "KCKContentSheetSwitchTableViewCell")
        self.mainTableView.allowsSelection = false
        self.mainTableView.allowsMultipleSelection = false
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setContentSwitchCell(cell: KCKContentSheetSwitchTableViewCell, index: Int) {
        super.setContentSwitchCell(cell: cell, index: index)
        
        cell.showMark = false
        cell.switchButton.isOn = self.dataSource[index].isOn
        cell.handleSwitch = { [weak self] switchButton in
            guard let strongSelf = self else { return }
            strongSelf.dataSource[index].isOn = switchButton.isOn
            strongSelf.delegate?.contentSheetSwitchTableView?(strongSelf, didSwitchButtonStatusIn: index, with: switchButton.isOn)
        }
        if let allowTouch = self.delegate?.contentSheetSwitchTableView?(self, canSwitchButtonIn: index) {
            cell.switchAllowTouch = allowTouch
        }
        if self.widgeAlignment != nil {
            cell.widgeAlignment = self.widgeAlignment!
        }
    }
    
    public func controlSwitch(index: Int, isOn: Bool) {
        let cell: KCKContentSheetSwitchTableViewCell = self.mainTableView.cellForRow(at: IndexPath(row: index, section: 0)) as! KCKContentSheetSwitchTableViewCell
        cell.switchButton.isOn = isOn
        self.dataSource[index].isOn = isOn
    }
    
    /**
     开关样式弹框。你可以实现 `KCKContentSheetSwitchTableViewDelegate` 来实现每个开关的操作，或者更多自定义操作。
     
     - Parameters:
        - title: 底部弹框标题，显示在最上面一行。若为 `nil` 则不显示标题行。
        - dataSource: `tableView` 的数据源。`tuple.0` 为 cell 的标题；`tuple.1` 为 cell 图标的 `url` 地址，若 `url` 为 `nil`，则图标不显示；`tuple.2` 为某个开关是否打开。
        - delegate: 代理对象。
        - inViewController: 默认弹框视图添加在主窗口上，但是你也可以选择将视图添加在当前活跃的控制器上。
        - viewConfiguration: 可以对弹框视图进行某些设置。
        - completionHandler: 在此样式下，该回调返回 `tableView` 的数据源，数据源保持原来的元组格式并记录了每个开关的状态。
        - cancelHandler: 若标题设置为 `nil`，即不显示标题行，那么设置此属性无任何效果。若标题行显示，并且显示了 `x` 按钮，则点击 `x` 按钮将执行此回调。
     */
    public static func show(title: String?, dataSource: [(title: String, url: String?, isOn: Bool)], delegate: KCKContentSheetSwitchTableViewDelegate?, inViewController: Bool = false, viewConfiguration: ((_ switchTableView: KCKContentSheetSwitchTableView) -> Void)? = nil, completionHandler: ((_ dataSource: [(title: String, url: String?, isOn: Bool)]) -> Void)?, cancelHandler: (() -> Void)?) {
        let switchTableView: KCKContentSheetSwitchTableView = KCKContentSheetSwitchTableView()
        switchTableView.title = title
        switchTableView.cancelHandler = cancelHandler
        viewConfiguration?(switchTableView)
        switchTableView.delegate = delegate
        
        switchTableView.dataSource.removeAll()
        for item in dataSource {
            switchTableView.dataSource.append(KCKContentSheetTableView.DataModel(title: item.title, iconURL: item.url, isOn: item.isOn))
        }
        switchTableView.mainTableView.reloadData()
        
        KCKContentSheetView.show(customView: switchTableView, contentHeight: switchTableView.defaultContentHeight) { sheetView in
            switchTableView.sheetViewDefaultSetting(sheetView: sheetView)
        } completionHandler: {
            var dataSource: [(title: String, url: String?, isOn: Bool)] = []
            for item in switchTableView.dataSource {
                dataSource.append((title: item.title, url: item.iconURL, isOn: item.isOn))
            }
            completionHandler?(dataSource)
        }
    }
}
