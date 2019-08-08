//
//  KeyboardAttachViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class KeyboardAttachViewController: UIViewControllerWithActivityIndicator {
  
  var keyboardAttachInfo: KeyboardAttachInfo?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initKeyboardNotifications()
  }
  
  @objc func keyboardWillShow(sender: NSNotification) {
    let userInfo = sender.userInfo!
    guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
      return
    }
    let keyboardDurationKey = UIResponder.keyboardAnimationDurationUserInfoKey
    guard let keyboardAnimationDuration = userInfo[keyboardDurationKey] as? NSNumber else {
      return
    }
    let keyboardAppearAnimationDuration: TimeInterval = keyboardAnimationDuration.doubleValue
    keyboardAttachInfo = KeyboardAttachInfo(
      height: keyboardFrame.cgRectValue.height ,
      duration: keyboardAppearAnimationDuration
    )
  }
  
  @objc func keyboardWillHide(sender: NSNotification) {
    keyboardAttachInfo = nil
  }
  
  func initKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(sender:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(sender:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
}

struct KeyboardAttachInfo {
  let height: CGFloat
  let duration: TimeInterval
}
