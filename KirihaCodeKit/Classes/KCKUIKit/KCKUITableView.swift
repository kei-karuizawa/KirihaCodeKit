//
//  KCKUITableView.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2021/11/7.
//

import UIKit

public extension UITableView {
    
    enum KCKStyle: Int {
        case plain = 0
        case grouped = 1
        case sidebar = 2
    }
    
}

open class KCKUITableView: UITableView {
    
    private var _sh_style: KCKUITableView.KCKStyle!
    open var sh_style: KCKUITableView.KCKStyle {
        return self._sh_style
    }
    
    open var enableTouchToCancelAllEditing: Bool = true
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }

    public init(frame: CGRect, shStyle: KCKUITableView.KCKStyle) {
        switch shStyle {
        case .plain:
            super.init(frame: frame, style: .plain)
        case .grouped:
            super.init(frame: frame, style: .grouped)
        case .sidebar:
            super.init(frame: frame, style: .grouped)
            self._sh_style = shStyle
        }        
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIWindow.kiriha_securyWindow()?.endEditing(self.enableTouchToCancelAllEditing)
    }
}
