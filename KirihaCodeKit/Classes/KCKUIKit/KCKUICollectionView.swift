//
//  KCKUICollectionView.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2021/11/6.
//

import UIKit

open class KCKUICollectionView: UICollectionView {

    open var enableTouchToCancelAllEditing: Bool = true

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIWindow.kiriha_securyWindow()?.endEditing(self.enableTouchToCancelAllEditing)
    }
    
}
