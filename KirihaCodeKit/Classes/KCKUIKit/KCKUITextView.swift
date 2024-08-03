//
//  KCKUITextView.swift
//  Kiriha
//
//  Created by 河瀬雫 on 2021/12/2.
//

import UIKit

open class KCKUITextView: UITextView, UITextViewDelegate {

    open var placeholder: String? {
        didSet {
            if let text = self.text {
                if text.count == 0 {
                    self.text = self.placeholder
                    self.textColor = UIColor.kiriha_colorWithHexString("#B4B4B4")
                }
            }
        }
    }
    
    override open var text: String! {
        didSet {
            self.changeTextStatus()
        }
    }
    
    open var maxCharactersEnable: Int = 32
    
    open var editCallBack: ((_ text: String) -> Void)?
    open var textViewDidBeginEditingHandler: ((_ textView: UITextView) -> Void)?
    open var textViewDidEndEditingHandler: ((_ textView: UITextView) -> Void)?
    
    let placeholderColor: UIColor = UIColor.kiriha_colorWithHexString("#B4B4B4")
    let normalTextColor: UIColor = UIColor.kiriha_colorWithHexString("#333333")
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.length + range.location > textView.text.count {
            return false
        }
        let newLength: Int = textView.text.count + text.count - range.length
        return newLength <= self.maxCharactersEnable
    }
    
    private func changeTextStatus() {
        if self.text == self.placeholder {
            if self.isFirstResponder {
                self.textColor = self.normalTextColor
            } else {
                self.textColor = self.placeholderColor
            }
        } else {
            self.textColor = self.normalTextColor
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        self.changeTextStatus()
        self.editCallBack?(textView.text)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count < 1 {
            self.text = self.placeholder
            textView.textColor = self.placeholderColor
        }
        self.textViewDidEndEditingHandler?(textView)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == self.placeholder {
            self.text = ""
            textView.textColor = self.normalTextColor
        }
        self.textViewDidBeginEditingHandler?(textView)
    }

}
