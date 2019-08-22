//
//  UserDetailsSectionView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class UserDetailsSectionView: UIView {
  private let label = UILabel()
  private var childView: UIView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupView(with labelText: String, childView: UIView) {
    self.childView = childView
    sutupLabel(with: labelText)
    setupChildView(childView)
  }
  
  func isChildFirstResponder() -> Bool {
    return childView?.isFirstResponder ?? false
  }
  
  func getChildText() -> String? {
    if let textField = childView as? UITextField {
      guard let text = textField.text else {
        return nil
      }
      return validateChildText(text)
    }
    
    guard let textView = childView as? UITextView else {
      return nil
    }
    return validateChildText(textView.text)
  }
  
  private func validateChildText(_ text: String) -> String? {
    if text.isEmpty {
      return nil
    }
    return text
  }
  
  func setChildText(_ text: String) {
    if let textField = childView as? UITextField {
      textField.text = text
    }
    
    if let textView = childView as? UITextView {
      textView.text = text
    }
  }
  
  private func sutupLabel(with text: String) {
    label.style({ v in
      v.text = text
      v.textColor = UIColor.gray800()
      v.font = UIFont(name: "CeraPro-Medium", size: 16)
      v.numberOfLines = 1
    })
    
    sv(label)
    label.top(0).left(10).right(0).height(15)
  }
  
  private func setupChildView(_ childView: UIView) {
    sv(childView)
    childView.Top == label.Bottom + 7
    childView.bottom(0).left(0).right(0)
  }
}
