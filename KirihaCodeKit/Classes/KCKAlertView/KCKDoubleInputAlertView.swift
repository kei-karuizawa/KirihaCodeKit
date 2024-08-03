//
//  KCKDoubleInputAlertView.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2022/7/12.
//

import Foundation

open class KCKDoubleInputAlertView: KCKInputAlertView {
    
    var firstTitle: String = "运单号"
    var secondtitle: String = "手机号"
    
    open var firstTitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "运单号"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.defaultLabelColor
        return label
    }()
    
    open var secondTitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "手机号"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.defaultLabelColor
        return label
    }()
    
    open var secondTextField: KCKUITextField = {
        let textField: KCKUITextField = KCKUITextField()
        textField.layer.borderColor = UIColor(red: 230 / 255.0, green: 230 / 255.0, blue: 230 / 255.0, alpha: 1.0).cgColor
        textField.layer.borderWidth = 0.5
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private var regular1: String?
    private var regular2: String?
    private var warnTip1: String?
    private var warnTip2: String?
    
    private let errorTip1: String = "第一个输入框的值不满足正则条件！"
    private let errorTip2: String = "第二个输入框的值不满足正则条件！"
    
    private var confirmActionWithView: ((_ inputAlertView: KCKDoubleInputAlertView) -> Void)?
    
    override func setInputViewUI() {
        self.addSubview(self.contentView)
        
        self.firstTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.contentView.addSubview(self.firstTitleLabel)
        self.firstTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12).priority(.high)
            make.top.equalToSuperview().offset(28).priority(.high)
        }
        
        self.textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        self.contentView.addSubview(self.textField)
        self.textField.snp.makeConstraints { make in
            make.left.equalTo(self.firstTitleLabel.snp.right).offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(48)
        }
        
        self.secondTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.contentView.addSubview(self.secondTitleLabel)
        self.secondTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12).priority(.high)
            make.top.equalTo(self.firstTitleLabel.snp.bottom).offset(44).priority(.high)
        }
        
        self.secondTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        self.contentView.addSubview(self.secondTextField)
        self.secondTextField.snp.makeConstraints { make in
            make.left.equalTo(self.secondTitleLabel.snp.right).offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(self.textField.snp.bottom).offset(16)
            make.height.equalTo(48)
        }
        
        self.contentView.addSubview(self.warnLabel)
        self.warnLabel.snp.makeConstraints { make in
            make.left.equalTo(self.secondTextField.snp.left)
            make.top.equalTo(self.secondTextField.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-10)
        }
        self.warnLabel.isHidden = true
    }
    
    override func handleConfirmAction(sender: KCKUIButton) {
        // 第一个正则有值。
        if let regex: String = self.regular1 {
            let regexRule: NSPredicate = NSPredicate(format: "SELF MATCHES %@" , regex)
            // 满足第一个正则。
            if regexRule.evaluate(with: self.textField.text ?? "") {
                // 第二个正则有值。
                if let regex2: String = self.regular2 {
                    let regexRule2: NSPredicate = NSPredicate(format: "SELF MATCHES %@" , regex2)
                    // 满足第一个正则的同时满足第二个正则。
                    if regexRule2.evaluate(with: self.secondTextField.text ?? "") {
                        self.confirmActionWithView?(self)
                        self.dismiss()
                    // 满足第一个正则，但不满足第二个正则。
                    } else {
                        self.warnLabel.text = self.warnTip2 ?? self.errorTip2
                        self.playAnimation()
                        self.showWarn()
                    }
                // 第一个正则有值，第二个正则没值，所以不需要判断第二个正则。
                } else {
                    self.confirmActionWithView?(self)
                    self.dismiss()
                }
            // 不满足第一个正则，直接抛错。
            } else {
                self.warnLabel.text = self.warnTip1 ?? self.errorTip1
                self.playAnimation()
                self.showWarn()
            }
        // 第一个正则没有值。
        } else {
            // 第二个正则有值。
            if let regex2: String = self.regular2 {
                let regexRule2: NSPredicate = NSPredicate(format: "SELF MATCHES %@" , regex2)
                // 满足第二个正则。
                if regexRule2.evaluate(with: self.secondTextField.text ?? "") {
                    self.confirmActionWithView?(self)
                    self.dismiss()
                // 不满足第二个正则。
                } else {
                    self.warnLabel.text = self.warnTip2 ?? self.errorTip2
                    self.playAnimation()
                    self.showWarn()
                }
            // 第二个正则没有值。
            } else {
                self.confirmActionWithView?(self)
                self.dismiss()
            }
        }
    }
    
    override func showWarn() {
        self.warnLabel.isHidden = false
    }
    
    /**
     带两个输入框的警告框，底部有两个按钮。
     
     - Parameters:
        - title: 警告弹框标题。若为 `nil` 则不显示标题行。
        - subTitles: 输入框左边的小标题。为 `nil` 或空则不显示。数组需要传入两个值，分别代表第一个输入框和第二个输入框的小标题。请注意确保数组传入两个值，否则会报错。下同。
        - placeholders: 两个输入框默认显示字符。
        - regulars: 正则表达式。当此值不为空时，若输入的字符串不满足正则，则会警告；若该值为 `nil`，则不进行正则判断。数组任意一个元素传 `nil` 代表对应的输入框不进行正则判断。
        - warnTips: 在 `regulars` 分别不为 `nil` 的情况下该值有效，若输入的字符串不满足正则，则为在输入框底下弹出警告字符串。
        - inViewController: 默认弹框视图添加在主窗口上，但是你也可以选择将视图添加在当前活跃的控制器上。
        - viewConfiguration: 可以对弹框视图进行某些设置。
        - cancelAction: 点击左边取消按钮的事件。
        - confirmAction: 点击右边确定按钮的事件。
     */
    public static func show(title: String?, subTitles: [String?]?, placeholders: [String?]?, regulars: [String?]? = nil, warnTips: [String?]? = nil, inViewController: Bool = false, viewConfiguration: ((_ inputAlertView: KCKDoubleInputAlertView) -> Void)?, cancelAction: (() -> Void)?, confirmAction: @escaping ((_ inputAlertView: KCKDoubleInputAlertView) -> Void)) {
        let inputAlertView: KCKDoubleInputAlertView = KCKDoubleInputAlertView()
        inputAlertView.firstTitleLabel.text = subTitles?[0]
        inputAlertView.secondTitleLabel.text = subTitles?[1]
        inputAlertView.textField.placeholder = placeholders?[0]
        inputAlertView.secondTextField.placeholder = placeholders?[1]
        inputAlertView.regular1 = regulars?[0]
        inputAlertView.regular2 = regulars?[1]
        inputAlertView.warnTip1 = warnTips?[0]
        inputAlertView.warnTip2 = warnTips?[1]
        viewConfiguration?(inputAlertView)
        inputAlertView.confirmActionWithView = confirmAction
        inputAlertView.addView(title: title, customView: inputAlertView.contentView, inViewController: inViewController, cancelAction: cancelAction, confirmAction: {})
    }
}
