//
//  KCKUIImageView.swift
//  Kiriha
//
//  Created by 河瀬雫 on 2021/12/23.
//

import Foundation
import SDWebImage
import UIKit

public extension UIImageView {
    
    func kiriha_loadImage(with url: String) {
        guard let url = URL.init(string: url) else {
            return
        }
        self.sd_setImage(with: url, completed: nil)
    }
    
}
