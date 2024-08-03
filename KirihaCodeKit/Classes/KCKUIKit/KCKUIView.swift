//
//  KCKUIView.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2021/11/6.
//

import UIKit
import SnapKit

open class KCKUIView: UIView {
    
    open var enableTouchToCancelAllEditing: Bool = true
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIWindow.kiriha_securyWindow()?.endEditing(self.enableTouchToCancelAllEditing)
    }

}

extension UIView {
    
    /**
     利用 `CABasicAnimation` 产生一次简单的动画。动画在完成后默认会使视图停留在动画结束后的位置。
     
     - Parameters:
        - key: 动画标识符。
        - keyPath: 指定哪个属性产生动画。
        - from: 从什么数值开始。
        - to: 从什么数值结束。
        - duration: 动画持续时间。
        - isRemoveOnCompletion: 是否完成后移除动画。
        - fillMode: 动画模式。
        - completionHandler: 动画完成后的回调。
     */
    public func kiriha_addSimpleOnceAnimation(key: String, keyPath: String,
                                             from fromValue: CGFloat, to toValue: CGFloat,
                                             duration: CGFloat, isRemoveOnCompletion: Bool = false,
                                             fillMode: CAMediaTimingFillMode = .forwards,
                                             completionHandler: (() -> Void)?) {
        self.layer.removeAnimation(forKey: key)
        CATransaction.begin()
        let animation: CABasicAnimation = CABasicAnimation()
        animation.keyPath = keyPath
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = CFTimeInterval(duration)
        animation.isRemovedOnCompletion = isRemoveOnCompletion
        animation.fillMode = fillMode
        CATransaction.setCompletionBlock {
            completionHandler?()
        }
        self.layer.add(animation, forKey: key)
        CATransaction.commit()
    }
}

public extension UIView {
    
    enum CornerPosition {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case all
    }
    
    func kiriha_addRoundedCorners(cornerPositons: [UIView.CornerPosition], radius: CGFloat) {
        var corners: UInt = CACornerMask().rawValue
        for corner in cornerPositons {
            switch corner {
            case .topLeft:
                corners = corners | CACornerMask.layerMinXMinYCorner.rawValue
            case .topRight:
                corners = corners | CACornerMask.layerMaxXMinYCorner.rawValue
            case .bottomLeft:
                corners = corners | CACornerMask.layerMinXMaxYCorner.rawValue
            case .bottomRight:
                corners = corners | CACornerMask.layerMaxXMaxYCorner.rawValue
            case .all:
                corners = corners | CACornerMask.layerMinXMinYCorner.rawValue | CACornerMask.layerMaxXMinYCorner.rawValue | CACornerMask.layerMinXMaxYCorner.rawValue | CACornerMask.layerMaxXMaxYCorner.rawValue
            }
        }
        if #available(iOS 11.0, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = CACornerMask(rawValue: corners)
        } else {
            
        }
    }
    
}

public extension UIView {

    enum SeparatorPositon {
        case top
        case bottom
    }
    
    func kiriha_addSeparator(color: UIColor = UIColor.kiriha_colorWithHexString("#F2F3F7"),
                            position: UIView.SeparatorPositon = .bottom,
                            leftEdge: CGFloat = 0, rightEdge: CGFloat = 0) {
        let aLine: UIView = UIView()
        aLine.backgroundColor = color
        self.addSubview(aLine)
        if position == .top {
            aLine.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(leftEdge)
                make.right.equalToSuperview().offset(-rightEdge)
                make.top.equalToSuperview()
                make.height.equalTo(1)
            }
        } else if position == .bottom {
            aLine.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(leftEdge)
                make.right.equalToSuperview().offset(-rightEdge)
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
        }
    }
}
