//
//  KCKSingleButtonAlertView.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2022/6/22.
//

import Foundation

open class KCKSingleButtonAlertView: KCKAlertView {
    
    override func setUI() {
        for (index, view) in self.allViews.enumerated() {
            self.mainContentView.addSubview(view)
            
            if view == self.titleLabel {
                self.titleLabel.text = self.title
                view.snp.makeConstraints { make in
                    make.left.right.top.equalToSuperview()
                    make.height.equalTo(56)
                }
                if self.showTitleSeparator {
                    view.kiriha_addSeparator(color: self.separatorColor, position: .bottom, leftEdge: self.separatorEdge, rightEdge: self.separatorEdge)
                }
            } else {
                let preView: UIView? = index == 0 ? nil : self.allViews[index - 1]
                view.snp.remakeConstraints { make in
                    make.left.equalToSuperview().offset(self.leftViewEdge)
                    make.right.equalToSuperview().offset(-self.leftViewEdge)
                    if preView != nil {
                        make.top.equalTo(preView!.snp.bottom).offset(0)
                    } else {
                        make.top.equalToSuperview().offset(self.viewEdge)
                    }
                }
            }
        }
        
        let lastView: UIView? = self.allViews.last
        let firstButton: KCKUIButton = self.confirmButton
        self.mainContentView.addSubview(firstButton)
        firstButton.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            if lastView != nil {
                make.top.equalTo(lastView!.snp.bottom).offset(self.viewEdge)
            } else {
                make.top.equalToSuperview().offset(self.viewEdge)
            }
            make.height.equalTo(CGFloat.kiriha_verticalSize(num: 58))
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(CGFloat.kiriha_verticalSize(num: 0))
        }
        firstButton.kiriha_addSeparator(color: self.separatorColor, position: .top, leftEdge: self.separatorEdge, rightEdge: self.separatorEdge)
    }
}
