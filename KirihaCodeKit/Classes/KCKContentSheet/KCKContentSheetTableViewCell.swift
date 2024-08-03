//
//  KCKContentSheetTableViewCell.swift
//  Kiriha
//
//  Created by 河瀬雫 on 2022/1/10.
//

import Foundation

class KCKContentSheetTableViewCell: UITableViewCell {
    
    var markButton: KCKUIButton = {
        let button: KCKUIButton = KCKUIButton()
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "checkmark"), for: .normal)
            button.tintColor = UIColor.defaultLabelColor
        } else {
            button.setImage(UIImage.kiriha_imageInKirihaBundle(name: "checkmark"), for: .normal)
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.isUserInteractionEnabled = false
        return button
    }()
    
    var showMark: Bool = true  // 多选视图下是否显示选中后的打钩标记。
    
    var iconImageView: UIImageView?
    var titleLabel: KCKUILabel!
    
    var showIcon: Bool = true
    
    private var hasAddSeparator: Bool = false
    var showSeparator: Bool = true
    
    var widgeAlignment: KCKContentSheetTableView.WidgeAlignment = .center
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if self.showIcon {
            self.iconImageView = UIImageView()
            self.iconImageView!.contentMode = .scaleAspectFit
            self.contentView.addSubview(self.iconImageView!)
            
            self.titleLabel = KCKUILabel()
            self.titleLabel.text = "中通快递"
            self.titleLabel.font = .systemFont(ofSize: 16)
            self.contentView.addSubview(self.titleLabel)
        } else {
            self.titleLabel = KCKUILabel()
            self.titleLabel.text = "中通快递"
            self.titleLabel.font = .systemFont(ofSize: 16)
            self.contentView.addSubview(self.titleLabel)
        }
        
        self.contentView.addSubview(self.markButton)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func layoutSubviews() {
        if self.showIcon {
            if self.iconImageView != nil {
                let edge: CGFloat = self.widgeAlignment == .left ? 20 : 140
                self.iconImageView!.snp.remakeConstraints { make in
                    make.left.equalToSuperview().offset(edge)
                    make.centerY.equalToSuperview()
                    make.width.height.equalTo(24)
                }
            }
            if self.titleLabel != nil {
                self.titleLabel.textAlignment = .left
                self.titleLabel.snp.remakeConstraints { make in
                    make.left.equalTo(self.iconImageView!.snp.right).offset(8)
                    make.centerY.equalToSuperview()
                    make.width.greaterThanOrEqualTo(64)
                    make.height.greaterThanOrEqualTo(16)
                }
            }
        } else {
            if self.titleLabel != nil {
                self.titleLabel.textAlignment = .center
                if self.widgeAlignment == .left {
                    let edge: CGFloat = self.widgeAlignment == .left ? 20 : 140
                    self.titleLabel.snp.remakeConstraints { make in
                        make.left.equalToSuperview().offset(edge)
                        make.centerY.equalToSuperview()
                        make.width.greaterThanOrEqualTo(64)
                        make.height.greaterThanOrEqualTo(16)
                    }
                } else {
                    self.titleLabel.snp.remakeConstraints { make in
                        make.centerX.equalToSuperview()
                        make.centerY.equalToSuperview()
                        make.width.greaterThanOrEqualTo(64)
                        make.height.greaterThanOrEqualTo(16)
                    }
                }
            }
        }
        
        if self.showSeparator && self.hasAddSeparator == false {
            self.contentView.kiriha_addSeparator(color: UIColor.kiriha_colorWithHexString("#D8D8D8", alpha: 0.5), position: .bottom, leftEdge: 16, rightEdge: 18)
            self.hasAddSeparator = true
        }
        
        
        if self.showMark {
            self.markButton.isHidden = false
            self.markButton.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-20)
                make.centerY.equalTo(self.titleLabel)
                make.width.height.equalTo(20)
            }
        } else {
            self.markButton.isHidden = true
        }
    }
}
