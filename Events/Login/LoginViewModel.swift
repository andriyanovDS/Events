//
//  LoginViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import FirebaseAuth
import RxSwift
import RxCocoa
import RxFlow

class LoginViewModel: Stepper {
  let steps = PublishRelay<Step>()

  weak var delegate: LoginViewModelDelegate!
  private let emailPattern = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
  
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
    
    delegate.showActivityIndicator(for: nil)
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] (_, error) in
      self?.delegate.removeActivityIndicator()
      if error != nil {
        onLoginFailed()
        return
      }
      self?.steps.accept(EventStep.home)
    }
  }
  
  func trySignUp(email: String, password: String, onSignUpFailed: @escaping (String) -> Void) {
    guard validateEmail(text: email) && validatePassword(text: password) else {
      return
    }
    delegate.showActivityIndicator(for: nil)
    Auth.auth().createUser(withEmail: email, password: password) { [weak self] (_, error) in
      self?.delegate.removeActivityIndicator()
      if let signUpError = error {
        onSignUpFailed(signUpError.localizedDescription)
        return
      }
      self?.steps.accept(EventStep.home)
    }
  }
}

protocol LoginViewModelDelegate: UIViewControllerWithActivityIndicator {}
