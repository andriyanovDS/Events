//
//  LoginViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import FirebaseAuth

class LoginViewModel {
  var coordinator: LoginCoordinator?
  let showActivityIndicator: (UIView?) -> Void
  let removeActivityIndicator: () -> Void
  private let emailPattern = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
  
  init(showActivityIndicator: @escaping (UIView?) -> Void, removeActivityIndicator: @escaping () -> Void) {
    self.showActivityIndicator = showActivityIndicator
    self.removeActivityIndicator = removeActivityIndicator
  }
  
  func validateEmail(text: String) -> Bool {
    
    if text.count == 0 {
      return true
    }
    
    let range = text.range(
      of: emailPattern,
      options: .regularExpression,
      range: nil,
      locale: nil
    )
    return range != nil
  }
  
  func validatePassword(text: String) -> Bool {
    return text.count >= 6
  }
  
  func tryLogin(email: String, password: String, onLoginFailed: @escaping () -> Void) {
    guard validateEmail(text: email) && validatePassword(text: password) else {
      return
    }
    
    showActivityIndicator(nil)
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] (_, error) in
      self?.removeActivityIndicator()
      if error != nil {
        onLoginFailed()
        return
      }
      self?.coordinator?.openRootScreen()
    }
  }
  
  func trySignUp(email: String, password: String, onSignUpFailed: @escaping (String) -> Void) {
    guard validateEmail(text: email) && validatePassword(text: password) else {
      return
    }
    showActivityIndicator(nil)
    Auth.auth().createUser(withEmail: email, password: password) { [weak self] (_, error) in
      self?.removeActivityIndicator()
      if let signUpError = error {
        onSignUpFailed(signUpError.localizedDescription)
        return
      }
      self?.coordinator?.openRootScreen()
    }
  }
}
