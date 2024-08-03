//
//  KCKUITextField.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2022/2/14.
//

import Foundation

open class KCKUITextField: UITextField, UITextFieldDelegate {
    
    open var maxCharactersEnable: Int = 32
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 15.0, dy: 0)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 15.0, dy: 0)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let length = textField.text?.count else {
            return true
        }
        if range.length + range.location > length {
            return false
        }
        let newLength: Int = length + string.count - range.length
        return newLength <= self.maxCharactersEnable
    }
    
}
