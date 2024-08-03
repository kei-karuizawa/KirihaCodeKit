//
//  KCKContentSheetView.swift
//  Kiriha
//
//  Created by 河瀬雫 on 2021/11/10.
//

import UIKit
import SnapKit

// MARK: - KCKContentSheetView.

open class KCKContentSheetView: KCKUIView {
    
    private static var sharedView: KCKContentSheetView?

    private var backgroundView: KCKUIView!
    private var mainContentView: KCKUIView!
    private var sepratorLine: KCKUIView!
    private var cancelButton: KCKUIButton!
    private var mainView: KCKUIView!
    
    private var mainViewHeight: CGFloat = 0
    private var contentHeight: CGFloat {
        var height: CGFloat = self.mainViewHeight
        height += 56 + UIWindow.kiriha_safeAreaInsets().bottom
        height += 8
        return height
    }
    
    open var completionHandler: (() -> Void)?
    
    /// 自定义底部按钮标题。
    public var actionTitle: String = "取消" {
        willSet {
            self.cancelButton.setTitle(newValue, for: .normal)
        }
    }
    
    /// 自定义动画时间。
    public var animationDuration: CGFloat = 0.5
            
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        self.backgroundView = KCKUIView()
        //self.backgroundView.backgroundColor = UIColor.kiriha_colorWithHexString("#000000", alpha: 0.7)
        self.backgroundView.backgroundColor = .white
        self.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        self.mainContentView = KCKUIView()
        self.backgroundView.addSubview(self.mainContentView)
        self.mainContentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
        
        self.cancelButton = KCKUIButton()
        self.cancelButton.backgroundColor = .white
        self.cancelButton.setTitle(self.actionTitle, for: .normal)
        self.cancelButton.setTitleColor(.black, for: .normal)
        self.cancelButton.titleLabel?.bounds = self.cancelButton.bounds
        self.cancelButton.titleLabel?.textAlignment = .center
        self.cancelButton.titleLabel?.font = .systemFont(ofSize: 17)
        self.cancelButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: UIWindow.kiriha_safeAreaInsets().bottom, right: 0)
        self.cancelButton.layer.backgroundColor = UIColor.white.cgColor
        self.cancelButton.addTarget(self, action: #selector(self.touchCancelAction(sender:)), for: .touchUpInside)
        self.mainContentView.addSubview(self.cancelButton)
        self.cancelButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(56 + UIWindow.kiriha_safeAreaInsets().bottom)
        }
        
        self.sepratorLine = KCKUIView()
        self.sepratorLine.backgroundColor = UIColor.kiriha_colorWithHexString("#F2F2F2")
        self.mainContentView.addSubview(self.sepratorLine)
        self.sepratorLine.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.cancelButton.snp.top)
            make.height.equalTo(8)
        }
        
        self.mainView = KCKUIView()
        self.mainView.backgroundColor = .white
        self.mainContentView.addSubview(self.mainView)
        self.mainView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.sepratorLine.snp.top).offset(0)
            make.height.equalTo(self.mainViewHeight)
        }
        
        self.mainContentView.clipsToBounds = true
    }
    
    /**
     该方法可以从底下弹出自定义视图，默认底下会有一个取消按钮。
     
     - Parameters:
        - customView: 自定义视图。
        - contentHeight: 自定义视图的高度。
        - inViewController: 默认弹框视图添加在主窗口上，但是你也可以选择将视图添加在当前活跃的控制器上。
        - viewConfiguration: 可以对弹框视图进行某些设置。
        - completionHandler: 点击底部按钮的回调。
     */
    public static func show(customView: UIView, contentHeight: CGFloat, inViewController: Bool = false, viewConfiguration: ((_ sheetView: KCKContentSheetView) -> Void)? = nil, completionHandler: ((() -> Void)?)) {
        if Self.sharedView?.superview != nil {
            return
        }
        let sheetView: KCKContentSheetView = KCKContentSheetView()
        sheetView.completionHandler = completionHandler
        sheetView.mainView.addSubview(customView)
        customView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        sheetView.mainViewHeight = contentHeight
        if inViewController {
            UIViewController.kiriha_currentActivityViewController()?.view.addSubview(sheetView)
        } else {
            UIWindow.kiriha_securyWindow()?.addSubview(sheetView)
        }
        sheetView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        sheetView.mainContentView.kiriha_addRoundedCorners(cornerPositons: [.topLeft, .topRight], radius: 10)
        viewConfiguration?(sheetView)
        Self.sharedView = sheetView
        Self.sharedView?.showWithAnimation()
    }
    
    private func positonYAnimationShow() {
        let fromValue: CGFloat = CGFloat.kiriha_screenHeight + self.contentHeight / 2
        let toValue: CGFloat = CGFloat.kiriha_screenHeight - self.contentHeight + self.contentHeight / 2
        self.mainContentView.kiriha_addSimpleOnceAnimation(key: "positionY.animation.show", keyPath: "position.y", from: fromValue, to: toValue, duration: self.animationDuration, completionHandler: nil)
    }
    
    private func positonYAnimationDismiss() {
        let fromValue: CGFloat = CGFloat.kiriha_screenHeight - self.contentHeight + self.contentHeight / 2
        let toValue: CGFloat = CGFloat.kiriha_screenHeight + self.contentHeight / 2
        self.mainContentView.kiriha_addSimpleOnceAnimation(key: "positionY.animation.dismiss", keyPath: "position.y", from: fromValue, to: toValue, duration: self.animationDuration) { [weak self] in
            self?.dismissAllView()
        }
    }
    
    private func opacityAnimationShow() {
        let fromValue: CGFloat = 0.0
        let toValue: CGFloat = 1.0
        self.mainContentView.kiriha_addSimpleOnceAnimation(key: "opacity.animation.show", keyPath: "opacity", from: fromValue, to: toValue, duration: self.animationDuration, completionHandler: nil)
        self.backgroundView.kiriha_addSimpleOnceAnimation(key: "opacity.animation.show.backgroundView", keyPath: "opacity", from: fromValue, to: toValue, duration: self.animationDuration, completionHandler: nil)
    }
    
    private func opacityAnimationDismiss() {
        let fromValue: CGFloat = 1.0
        let toValue: CGFloat = 0.0
        self.mainContentView.kiriha_addSimpleOnceAnimation(key: "opacity.animation.dismiss", keyPath: "opacity", from: fromValue, to: toValue, duration: self.animationDuration, completionHandler: nil)
        self.backgroundView.kiriha_addSimpleOnceAnimation(key: "opacity.animation.dismiss.backgroundView", keyPath: "opacity", from: fromValue, to: toValue, duration: self.animationDuration, completionHandler: nil)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.mainView.snp.updateConstraints { make in
            make.height.equalTo(self.mainViewHeight)
        }
        
        self.mainContentView.snp.updateConstraints { make in
            make.height.equalTo(self.contentHeight)
        }
    }

    private func showWithAnimation() {
        self.positonYAnimationShow()
        self.opacityAnimationShow()
    }
    
    private func dismissWithAnimation() {
        self.positonYAnimationDismiss()
        self.opacityAnimationDismiss()
    }
    
    private func dismissAllView() {
        self.removeFromSuperview()
        Self.sharedView?.removeFromSuperview()
        Self.sharedView = nil
    }
    
    @objc private func touchCancelAction(sender: KCKUIButton) {
        self.dismissWithAnimation()
        self.completionHandler?()
    }
    
    @objc public static func dismiss() {
        Self.sharedView?.dismissWithAnimation()
    }
}
