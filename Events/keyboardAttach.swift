//
//  KeyboardAttach.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift

struct KeyboardAttachInfo {
	let height: CGFloat
	let duration: TimeInterval
}

private let keyboardWillShow$ = NotificationCenter.default.rx
  .notification(UIResponder.keyboardWillShowNotification)
  .map { sender -> KeyboardAttachInfo? in
     let userInfo = sender.userInfo!
     guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
       return nil
     }
     let keyboardDurationKey = UIResponder.keyboardAnimationDurationUserInfoKey
     guard let keyboardAnimationDuration = userInfo[keyboardDurationKey] as? NSNumber else {
       return nil
     }
     let keyboardAppearAnimationDuration: TimeInterval = keyboardAnimationDuration.doubleValue
     return KeyboardAttachInfo(
       height: keyboardFrame.cgRectValue.height,
       duration: keyboardAppearAnimationDuration
     )
  }

private let keyboardWillHide$ = NotificationCenter.default.rx
  .notification(UIResponder.keyboardWillHideNotification)
  .map { _ -> KeyboardAttachInfo? in nil }

let keyboardAttach$: Observable<KeyboardAttachInfo?> = Observable
	.merge(keyboardWillHide$, keyboardWillShow$)
	.debounce(.milliseconds(50), scheduler: MainScheduler.instance)
