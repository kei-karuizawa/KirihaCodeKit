//
//  KCKSideBarTableView.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2021/11/7.
//

import UIKit
import SnapKit

// MARK: - KCKSideBarHeaderView.

open class KCKSideBarHeaderView: KCKUIView {
    
    open var titleLabel: KCKUILabel?
    open var accessButton: KCKUIButton?
    
    open var touchAccessButtonHandle: ((_ button: KCKUIButton) -> Void)?
    
    private func initialize() {
        self.accessButton = KCKUIButton()
        self.accessButton!.setImage(UIImage.kiriha_imageInKirihaBundle(name: "arrow_down"), for: .normal)
        self.accessButton!.setImage(UIImage.kiriha_imageInKirihaBundle(name: "arrow_up"), for: .selected)
        self.accessButton!.isSelected = false
        self.accessButton!.addTarget(self, action: #selector(self.handleButton(sender:)), for: .touchUpInside)
        self.addSubview(self.accessButton!)
        self.accessButton!.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(CGFloat.kiriha_horizontalSize(num: -12))
            make.width.equalTo(CGFloat.kiriha_horizontalSize(num: 24))
        }
        
        self.titleLabel = KCKUILabel()
        self.titleLabel!.font = .systemFont(ofSize: CGFloat.kiriha_verticalSize(num: 16))
        self.titleLabel!.textAlignment = .left
        self.addSubview(titleLabel!)
        self.titleLabel!.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(CGFloat.kiriha_horizontalSize(num: 16))
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(self.accessButton!.snp.left).offset(CGFloat.kiriha_horizontalSize(num: -42))
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func handleButton(sender: KCKUIButton) {
        sender.isSelected = !sender.isSelected
        self.touchAccessButtonHandle?(sender)
    }
}

// MARK: - KCKSideBarTableView data.

extension KCKSideBarTableView {
    
    public struct KCKSideBarDataCellModel {
        public let title: String?
        public let detail: String?
        public let image: UIImage?
        
        public init(title: String?, detail: String?, image: UIImage?) {
            self.title = title
            self.detail = detail
            self.image = image
        }
    }
    
    public struct KCKSideBarDataModel {
        public let header: String
        public let contents: [KCKSideBarDataCellModel]
        
        public var isSelected: Bool = false
        
        public init(header: String, contents: [KCKSideBarDataCellModel]) {
            self.header = header
            self.contents = contents
        }
    }
}

// MARK: - KCKSideBarTableViewDelegate.

@objc public protocol KCKSideBarTableViewDelegate {
    
    @objc optional func sidebarTableView(_ sidebarTableView: KCKSideBarTableView, viewForHeaderInSection section: Int) -> KCKSideBarHeaderView?
}

// MARK: - KCKSideBarTableView.

open class KCKSideBarTableView: KCKUIView {
        
    open var models: [KCKSideBarTableView.KCKSideBarDataModel] = []
    
    open weak var delegate: KCKSideBarTableViewDelegate?
    
    open var headerHeight: CGFloat = CGFloat.kiriha_verticalSize(num: 56)
    open var rowHeight: CGFloat = CGFloat.kiriha_verticalSize(num: 56)
    
    open var dataSourceHandle: ((_ cell: UITableViewCell, _ indexPath: IndexPath) -> Void)?
    
    open var didSelectItemHandle: ((_ index: Int, _ section: Int) -> Void)?
    
    open var cellSeparatorStyle: UITableViewCell.SeparatorStyle = .none {
        willSet {
            self.sidebarTableView.separatorStyle = newValue
        }
    }
    open var cellSeparatorColor: UIColor = UIColor.kiriha_colorWithHexString("#D8D8D8", alpha: 0.5) {
        willSet {
            self.sidebarTableView.separatorColor = newValue
        }
    }
    
    private var sidebarTableView: KCKUITableView!
    
    private func initialize() {
        self.sidebarTableView = KCKUITableView(frame: CGRect.zero, style: .grouped)
        self.sidebarTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SideBarCell")
        self.sidebarTableView.rowHeight = self.rowHeight
        self.sidebarTableView.delegate = self
        self.sidebarTableView.dataSource = self
        self.sidebarTableView.sectionHeaderHeight = 0
        self.sidebarTableView.sectionFooterHeight = 0
        self.sidebarTableView.separatorStyle = .none
        self.sidebarTableView.separatorColor = self.cellSeparatorColor
        self.sidebarTableView.estimatedRowHeight = 0
        self.sidebarTableView.estimatedSectionFooterHeight = 0
        self.sidebarTableView.estimatedSectionHeaderHeight = 0
        self.addSubview(self.sidebarTableView)
        self.sidebarTableView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open func reloadSections(_ sets: [Int], with animation: UITableView.RowAnimation) {
        let isets: IndexSet = IndexSet(sets)
        self.sidebarTableView.reloadSections(isets, with: animation)
    }
    
    open func reloadData() {
        self.sidebarTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource.

extension KCKSideBarTableView: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.models[section].isSelected {
            return self.models[section].contents.count
        } else {
            return 0
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.models.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SideBarCell", for: indexPath)
        self.dataSourceHandle?(cell, indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate.

extension KCKSideBarTableView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let delegateHeaderView: KCKSideBarHeaderView? = self.delegate?.sidebarTableView?(self, viewForHeaderInSection: section)
        if delegateHeaderView == nil {
            let headerView: KCKSideBarHeaderView = KCKSideBarHeaderView()
            headerView.titleLabel?.text = self.models[section].header
            headerView.accessButton?.isSelected = self.models[section].isSelected
            headerView.touchAccessButtonHandle = { button in
                self.models[section].isSelected = button.isSelected
                let sets: IndexSet = IndexSet(integer: section)
                tableView.reloadSections(sets, with: .fade)
            }
            return headerView
        } else {
            return delegateHeaderView
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectItemHandle?(indexPath.row, indexPath.section)
    }
}
