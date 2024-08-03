//
//  KCKInputAlertView.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2022/3/15.
//

import Foundation

open class KCKInputAlertView: KCKAlertView {
    
    var contentView: KCKUIView = {
        let view: KCKUIView = KCKUIView()
        view.backgroundColor = UIColor.defaultViewColor
        return view
    }()
    
    open var textField: KCKUITextField = {
        let textField: KCKUITextField = KCKUITextField()
        textField.layer.borderColor = UIColor(red: 230 / 255.0, green: 230 / 255.0, blue: 230 / 255.0, alpha: 1.0).cgColor
        textField.layer.borderWidth = 0.5
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    open var warnLabel: KCKUILabel = {
        let label: KCKUILabel = KCKUILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.textColor = .red
        return label
    }()
    
    private var regular: String?
    private var warnTip: String?
    
    private var confirmActionWithView: ((_ inputAlertView: KCKInputAlertView) -> Void)?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setInputViewUI()
    }
    
    func setInputViewUI() {
        self.addSubview(self.contentView)
        
        self.textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        self.contentView.addSubview(self.textField)
        self.textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            //make.bottom.equalToSuperview().offset(CGFloat.kiriha_verticalSize(num: -12))
            make.height.equalTo(48)
        }
        
        self.contentView.addSubview(self.warnLabel)
        self.warnLabel.snp.makeConstraints { make in
            make.left.equalTo(self.textField.snp.left)
            make.top.equalTo(self.textField.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(0)
        }
        self.warnLabel.isHidden = true
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if textField.text == nil || textField.text == "" {
            self.hiddenWarn()
        }
    }
    
    override func handleConfirmAction(sender: KCKUIButton) {
        if let regex: String = self.regular {
            let regexRule: NSPredicate = NSPredicate(format: "SELF MATCHES %@" , regex)
            if regexRule.evaluate(with: self.textField.text ?? "") {
                self.confirmActionWithView?(self)
                self.dismiss()
            } else {
                self.playAnimation()
                self.showWarn()
            }
        } else {
            self.confirmActionWithView?(self)
            self.dismiss()
        }
    }
    
    func playAnimation() {
        let viewLayer: CALayer = self.mainContentView.layer
        viewLayer.removeAnimation(forKey: "position.animation.show")
        let positon: CGPoint = viewLayer.position
        let beginPosition: CGPoint = CGPoint(x: positon.x + 10, y: positon.y)
        let endPosition: CGPoint = CGPoint(x: positon.x - 10, y: positon.y)
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: .default)
        animation.fromValue = beginPosition
        animation.toValue = endPosition
        animation.autoreverses = true
        animation.duration = 0.06
        animation.repeatCount = 3
        viewLayer.add(animation, forKey: "position.animation.show")
    }
    
    func showWarn() {
        self.warnLabel.isHidden = false
        self.warnLabel.text = self.warnTip
    }
    
    func hiddenWarn() {
        self.warnLabel.isHidden = true
    }
    
    /**
     带一个输入框的警告框，底部有两个按钮。
     
     - Parameters:
        - title: 警告弹框标题。若为 `nil` 则不显示标题行。
        - placeholder: 输入框默认显示字符。
        - regular: 正则表达式。当此值不为空时，若输入的字符串不满足正则，则会警告；若该值为 `nil`，则不进行正则判断。
        - warnTip: 在 `regular` 不为 `nil` 的情况下该值有效，若输入的字符串不满足正则，则为在输入框底下弹出警告字符串。
        - inViewController: 默认弹框视图添加在主窗口上，但是你也可以选择将视图添加在当前活跃的控制器上。
        - viewConfiguration: 可以对弹框视图进行某些设置。
        - cancelAction: 点击左边取消按钮的事件。
        - confirmAction: 点击右边确定按钮的事件。
     */
    public static func show(title: String?, placeholder: String?, regular: String? = nil, warnTip: String? = nil, inViewController: Bool = false, viewConfiguration: ((_ inputAlertView: KCKInputAlertView) -> Void)?, cancelAction: (() -> Void)?, confirmAction: @escaping ((_ inputAlertView: KCKInputAlertView) -> Void)) {
        let inputAlertView: KCKInputAlertView = KCKInputAlertView()
        inputAlertView.textField.placeholder = placeholder
        inputAlertView.regular = regular
        inputAlertView.warnTip = warnTip
        viewConfiguration?(inputAlertView)
        inputAlertView.confirmActionWithView = confirmAction
        inputAlertView.addView(title: title, customView: inputAlertView.contentView, inViewController: inViewController, cancelAction: cancelAction, confirmAction: {})
    }
    
}
