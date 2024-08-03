//
//  KCKUILabel.swift
//  TXUtil
//
//  Created by 河瀬雫 on 2021/11/10.
//

import UIKit

open class KCKUILabel: UILabel {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.defaultViewColor
        self.textColor = UIColor.defaultLabelColor
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
