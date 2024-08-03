//
//  KCKProgressView.swift
//  Kiriha
//
//  Created by 河瀬雫 on 2022/1/14.
//

import Foundation
import UIKit

open class KCKProgressView: KCKUIView {
    
    private static var shared: KCKProgressView = KCKProgressView()
    
    private var backgroundView: KCKUIView = {
        let view: KCKUIView = KCKUIView()
        view.backgroundColor = UIColor.kiriha_colorWithHexString("#000000", alpha: 0.7)
        return view
    }()
    
    private var activityContainView: KCKUIView = {
        let view: KCKUIView = KCKUIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.kiriha_addRoundedCorners(cornerPositons: [.all], radius: 10)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = 6.0
        view.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        return view
    }()
    
    private var activityView: UIActivityIndicatorView = {
        let view: UIActivityIndicatorView = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            view.style = .large
        }
        view.color = .white
        view.hidesWhenStopped = true
        return view
    }()
    
    private var progressEdge: CGFloat = 100
    
    private var signalLock: NSLock = NSLock()
    private var signal: Int = 0
    
    private var animationDuration: CGFloat = 0.3
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.backgroundView)
        self.addSubview(self.activityContainView)
        self.addSubview(self.activityView)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        self.activityContainView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(self.progressEdge)
        }
        self.activityView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    /**
     显示加载框。
     
     - Important: 若使用此方式显示加载框，则不管调用几次该方法，只需要调用一次 `KCKProgressView.dismiss()` 加载框就会消失。
     */
    public static func show() {
        Self.shared.signalLock.lock()
        Self.shared.signal = 1
        Self.shared.signalLock.unlock()
        if Self.shared.superview != nil {
            return
        }
        let progressView: KCKProgressView = Self.shared
        UIWindow.kiriha_securyWindow()?.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        progressView.activityView.startAnimating()
    }
    
    /**
     显示加载框。
     
     - Important: 若使用此方式显示加载框，则调用了几次该方法就必须对应调用几次 `KCKProgressView.dismiss()` 后加载框才会消失。
     该方法在一个页面内同时请求多条网络数据的情况下会很有用。
     */
    public static func showWithSignal() {
        Self.shared.signalLock.lock()
        Self.shared.signal += 1
        Self.shared.signalLock.unlock()
        if Self.shared.superview != nil {
            return
        }
        let progressView: KCKProgressView = Self.shared
        UIWindow.kiriha_securyWindow()?.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        progressView.activityView.startAnimating()
    }
    
    private func dismissAllView() {
        Self.shared.kiriha_addSimpleOnceAnimation(key: "opacity.animation.dismiss", keyPath: "opacity", from: 1.0, to: 0.0, duration: Self.shared.animationDuration) {
            Self.shared.activityView.stopAnimating()
            Self.shared.removeFromSuperview()
            Self.shared.kiriha_addSimpleOnceAnimation(key: "opacity.animation.dismiss", keyPath: "opacity", from: 0.0, to: 1.0, duration: Self.shared.animationDuration, completionHandler: nil)
        }
    }
    
    /**
     加载框消失。
     */
    public static func dismiss() {
        Self.shared.signalLock.lock()
        Self.shared.signal -= 1
        if Self.shared.signal < 0 {
            Self.shared.signal = 0
        }
        Self.shared.signalLock.unlock()
        if Self.shared.signal == 0 {
            Self.shared.dismissAllView()
        }
    }
    
    /**
     加载框消失。若在使用了多次 `KCKProgressView.showWithSignal()` 的情况下，使用此方法可以强制使加载框消失。
     */
    public static func dismissWithClearSignal() {
        Self.shared.signalLock.lock()
        Self.shared.signal = 0
        Self.shared.signalLock.unlock()
        Self.shared.dismissAllView()
    }
    
    /**
     获取当前计数。
     */
    public static func getSignal() -> Int {
        return Self.shared.signal
    }
}
