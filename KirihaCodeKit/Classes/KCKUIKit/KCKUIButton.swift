//
//  KCKUIButton.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2021/11/9.
//

import UIKit

open class KCKUIButton: UIButton {
    
    open var clickArea: CGFloat = 0.4

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentHorizontalAlignment = .fill
        self.contentVerticalAlignment = .fill
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        // 获取 bounds 实际大小。
        var bounds: CGRect = self.bounds
        
        let area: CGFloat = self.clickArea
        let width: CGFloat = max(44.0 - area * bounds.size.width, 0.0)
        let height: CGFloat = max(44.0 - area * bounds.size.height, 0.0)
        
        // 扩大 bounds。
        bounds = bounds.insetBy(dx: -0.5 * width, dy: -0.5 * height)
        
        return bounds.contains(point)
    }
    
}
