//
//  KCKCGFloat.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2021/11/6.
//

import UIKit

public extension CGFloat {
    
    static var kiriha_screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var kiriha_screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static func kiriha_horizontalRatio() -> CGFloat {
        return self.kiriha_screenWidth / 375.0
    }
    
    static func kiriha_verticalRatio() -> CGFloat {
        return self.kiriha_screenHeight / 812.0
    }
    
    static func kiriha_horizontalSize(num: CGFloat) -> CGFloat {
        return self.kiriha_horizontalRatio() * num
    }
    
    static func kiriha_verticalSize(num: CGFloat) -> CGFloat {
        return self.kiriha_verticalRatio() * num
    }
    
}
