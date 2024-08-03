//
//  KCKContentSheetDefaultTableView.swift
//  Kiriha
//
//  Created by 河瀬雫 on 2022/1/11.
//

import Foundation

open class KCKContentSheetDefaultTableView: KCKContentSheetTableView {
        
    private var selectedIndex: Int?
    
    private var completionHandler: ((_ index: Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.style = .default
        self.actionTitle = "取消"
        
        self.cancelButton.isHidden = true
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setTableView() {
        super.setTableView()
        
        self.mainTableView.register(KCKContentSheetTableViewCell.self, forCellReuseIdentifier: "KCKContentSheetTableViewCell")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setDefaultCell(cell: KCKContentSheetTableViewCell, index: Int) {
        super.setDefaultCell(cell: cell, index: index)
        
        if self.selectedIndex == nil {
            cell.showMark = false
            cell.widgeAlignment = .center
        } else {
            if index == self.selectedIndex! {
                cell.showMark = true
            } else {
                cell.showMark = false
            }
            cell.widgeAlignment = .left
        }
        if self.widgeAlignment != nil {
            cell.widgeAlignment = self.widgeAlignment!
        }
    }
    
    override func setDidSelectRowInDefaultStyle(index: Int) {
        super.setDidSelectRowInDefaultStyle(index: index)
        
        self.completionHandler?(index)
        KCKContentSheetView.dismiss()
    }
    
    /**
     默认单选样式弹框，点击某个 cell 后视图自动消失，并回传选择的行序号。
     
     - Parameters:
        - title: 底部弹框标题，显示在最上面一行。若为 `nil` 则不显示标题行。
        - dataSource: `tableView` 的数据源。`tuple.0` 为 cell 的标题；`tuple.1` 为 cell 图标的 `url` 地址。若 `url` 为 `nil`，则图标不显示。
        - selectedIndex: 是否默认选中某行，传 `nil` 不进行默认选中操作且每行内容居中，若传具体值，则对应行右边显示打钩标记，且每行内容居左。
        - inViewController: 默认弹框视图添加在主窗口上，但是你也可以选择将视图添加在当前活跃的控制器上。
        - viewConfiguration: 可以对弹框视图进行某些设置。
        - completionHandler: 点击某一行的回调，回传选择的行序号。
        - cancelHandler: 点击底部按钮的回调。若标题行显示，并且显示了 `x` 按钮，则点击 `x` 按钮也将执行此回调。
     */
    public static func show(title: String?, dataSource: [(title: String, url: String?)], selectedIndex: Int?, inViewController: Bool = false, viewConfiguration: ((_ defaultTableView: KCKContentSheetDefaultTableView) -> Void)? = nil, completionHandler: @escaping ((_ index: Int) -> Void), cancelHandler: (() -> Void)?) {
        let defaultTableView: KCKContentSheetDefaultTableView = KCKContentSheetDefaultTableView()
        defaultTableView.title = title
        defaultTableView.selectedIndex = selectedIndex
        defaultTableView.completionHandler = completionHandler
        defaultTableView.cancelHandler = cancelHandler
        viewConfiguration?(defaultTableView)
        
        defaultTableView.dataSource.removeAll()
        for (index, item) in dataSource.enumerated() {
            var isSelected: Bool = false
            if selectedIndex != nil && index == selectedIndex! {
                isSelected = true
            }
            defaultTableView.dataSource.append(KCKContentSheetTableView.DataModel(title: item.title, iconURL: item.url, isSelected: isSelected))
        }
        
        defaultTableView.mainTableView.reloadData()
        
        KCKContentSheetView.show(customView: defaultTableView, contentHeight: defaultTableView.defaultContentHeight, inViewController: inViewController) { sheetView in
            defaultTableView.sheetViewDefaultSetting(sheetView: sheetView)
        } completionHandler: {
            cancelHandler?()
        }
    }
}
