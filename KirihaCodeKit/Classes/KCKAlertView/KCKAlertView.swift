//
//  KCKAlertView.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2022/2/14.
//

import Foundation
import UIKit

@objcMembers
open class KCKAlertView: KCKUIView {
    
    private var defaultConfirmButtonTitleColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .light {
                    return UIColor.systemBlue
                } else {
                    return UIColor.blue
                }
            }
        } else {
            return UIColor.blue
        }
    }
    
    private var defaultCancelButtonTitleColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .light {
                    return UIColor.systemRed
                } else {
                    return UIColor.red
                }
            }
        } else {
            return UIColor.red
        }
    }
    
    private var backgroundView: KCKUIView = {
        let view: KCKUIView = KCKUIView()
        view.backgroundColor = UIColor.kiriha_colorWithHexString("#000000", alpha: 0.7)
        return view
    }()
    
    open var mainContentView: KCKUIView = {
        let view: KCKUIView = KCKUIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    open var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    open lazy var titleLabel: KCKUILabel = {
        let label: KCKUILabel = KCKUILabel()
        label.text = self.title
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private var cancelAction: (() -> Void)?
    open var cancelButton: KCKUIButton = {
        let button: KCKUIButton = KCKUIButton()
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private var confirmAction: (() -> Void)?
    open var confirmButton: KCKUIButton = {
        let button: KCKUIButton = KCKUIButton()
        button.setTitle("确认", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    /// 是否显示标题栏下面的分割线。
    open var showTitleSeparator: Bool = false
    
    var mainContentViewLeftViewEdge: CGFloat = 28
    var viewEdge: CGFloat = 10
    var leftViewEdge: CGFloat = 20
    var separatorEdge: CGFloat = 8.0
    var separatorColor: UIColor = UIColor.kiriha_colorWithHexString("#F2F3F7")
    
    var allViews: [UIView] = []
    
    /// 控制点击背景视图是否会让弹框消失。
    public var touchBackgroundToCancel: Bool = false {
        didSet {
            if self.touchBackgroundToCancel {
                self.addBackgroundViewGesture()
            } else {
                self.removeBackgroundViewGesture()
            }
        }
    }
    private var tapGesture: UITapGestureRecognizer?
            
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        self.addSubview(self.mainContentView)
        self.mainContentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(self.mainContentViewLeftViewEdge)
            make.right.equalToSuperview().offset(-self.mainContentViewLeftViewEdge)
            make.centerY.equalToSuperview()
        }
        
        self.cancelButton.setTitleColor(self.defaultCancelButtonTitleColor, for: .normal)
        self.cancelButton.addTarget(self, action: #selector(self.handleCancelAction(sender:)), for: .touchUpInside)
        
        self.confirmButton.setTitleColor(self.defaultConfirmButtonTitleColor, for: .normal)
        self.confirmButton.addTarget(self, action: #selector(self.handleConfirmAction(sender:)), for: .touchUpInside)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func handleCancelAction(sender: KCKUIButton) {
        self.cancelAction?()
        self.dismiss()
    }
    
    @objc func handleConfirmAction(sender: KCKUIButton) {
        self.confirmAction?()
        self.dismiss()
    }
    
    func dismiss() {
        self.isHidden = true
        self.removeFromSuperview()
    }
    
    func addBackgroundViewGesture() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleCancelAction(sender:)))
        self.tapGesture = tapGesture
        self.backgroundView.addGestureRecognizer(self.tapGesture!)
    }
    
    func removeBackgroundViewGesture() {
        if self.tapGesture != nil {
            self.backgroundView.removeGestureRecognizer(self.tapGesture!)
            self.tapGesture = nil
        }
    }
    
    func setUI() {
        for (index, view) in self.allViews.enumerated() {
            self.mainContentView.addSubview(view)
            
            if view == self.titleLabel {
                self.titleLabel.text = self.title
                view.snp.makeConstraints { make in
                    make.left.right.top.equalToSuperview()
                    make.height.equalTo(56)
                }
                if self.showTitleSeparator {
                    view.kiriha_addSeparator(color: self.separatorColor, position: .bottom, leftEdge: self.separatorEdge, rightEdge: self.separatorEdge)
                }
            } else {
                let preView: UIView? = index == 0 ? nil : self.allViews[index - 1]
                view.snp.remakeConstraints { make in
                    make.left.equalToSuperview().offset(self.leftViewEdge)
                    make.right.equalToSuperview().offset(-self.leftViewEdge)
                    if preView != nil {
                        make.top.equalTo(preView!.snp.bottom).offset(0)
                    } else {
                        make.top.equalToSuperview().offset(self.viewEdge)
                    }
                }
            }
        }
        
        let lastView: UIView? = self.allViews.last
        let firstButton: KCKUIButton = self.cancelButton
        let secondButton: KCKUIButton = self.confirmButton
        self.mainContentView.addSubview(firstButton)
        self.mainContentView.addSubview(secondButton)
        firstButton.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            if lastView != nil {
                make.top.equalTo(lastView!.snp.bottom).offset(self.viewEdge)
            } else {
                make.top.equalToSuperview().offset(self.viewEdge)
            }
            make.height.equalTo(58)
            make.width.equalTo(secondButton)
            make.right.equalTo(secondButton.snp.left)
            make.bottom.equalToSuperview().offset(0)
        }
        secondButton.snp.remakeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(firstButton.snp.top)
            make.height.equalTo(58)
            make.bottom.equalToSuperview().offset(0)
        }
        firstButton.kiriha_addSeparator(color: self.separatorColor, position: .top, leftEdge: self.separatorEdge, rightEdge: 0)
        secondButton.kiriha_addSeparator(color: self.separatorColor, position: .top, leftEdge: 0, rightEdge: self.separatorEdge)
        let line: KCKUIView = KCKUIView()
        line.backgroundColor = self.separatorColor
        self.mainContentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalTo(firstButton.snp.right)
            make.width.equalTo(1)
            make.top.equalTo(firstButton.snp.top).offset(14)
            make.bottom.equalTo(firstButton.snp.bottom).offset(-14)
        }
    }
    
    func addView(title: String?, customView: UIView, inViewController: Bool = false, cancelAction: (() -> Void)?, confirmAction: @escaping (() -> Void)) {
        if inViewController {
            UIViewController.kiriha_currentActivityViewController()?.view.addSubview(self)
        } else {
            UIWindow.kiriha_securyWindow()?.addSubview(self)
        }
        self.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        if title != nil {
            self.title = title
            self.allViews.insert(self.titleLabel, at: 0)
            self.allViews.insert(customView, at: 1)
        } else {
            self.allViews.insert(customView, at: 0)
        }
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
        self.setUI()
    }
}
