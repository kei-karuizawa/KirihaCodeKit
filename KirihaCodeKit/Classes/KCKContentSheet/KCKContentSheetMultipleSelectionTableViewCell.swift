//
//  KCKContentSheetMultipleSelectionTableViewCell.swift
//  Kiriha
//
//  Created by 河瀬雫 on 2022/1/10.
//

import Foundation

class KCKContentSheetMultipleSelectionTableViewCell: KCKContentSheetTableViewCell {
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.widgeAlignment = .left
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
