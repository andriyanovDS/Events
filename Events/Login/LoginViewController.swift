//
//  LoginViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 09/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift
import SwiftIconFont

class LoginViewController: UIViewControllerWithActivityIndicator, UITextFieldDelegate, LoginViewModelDelegate {
  var messageView: UIView?
  let loginButton = ButtonScale()
  let signInButton = ButtonScale()
  let backButton = UIButton()
  let textFieldWrapperView = UIView()
  let emailTextField = TextFieldWithShadow()
  let passwordTextField = TextFieldWithShadow()

  let loginButtonBottomPadding: CGFloat = 200.0
  var bottomConstraintForKeyboard: NSLayoutConstraint?
  var textFieldsTopLayoutConstraint: NSLayoutConstraint?
  var signInButtonTopLayoutConstraint: NSLayoutConstraint?

  var isEmailValid: Bool = false
  var isPasswordValid: Bool = false
  private let viewModel: LoginViewModel
  private let disposeBag = DisposeBag()

  init(viewModel: LoginViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)

    self.viewModel.delegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var authState: AuthState = .notSelected {
    willSet (nextState) {

      if authState == nextState {
        return
      }
      animateTextFields(forState: nextState)
      toggleBackButton(state: nextState)
      toggleLoginButton(state: nextState)
      toggleSignInButton(state: nextState)

      nextState.eitherL(
        notSelected: {
          loginButton.isEnabled = true
          signInButton.isEnabled = true
          emailTextField.text = ""
          passwordTextField.text = ""
      },
        selected: { state in
          if state == .login {
            loginButton.isEnabled = false
            return
          }
          signInButton.isEnabled = false
      }
      )
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    emailTextField.delegate = self
    passwordTextField.delegate = self

    setupView()

    emailTextField.addTarget(self, action: #selector(emailDidChange(_:)), for: .editingChanged)
    passwordTextField.addTarget(self, action: #selector(passwordDidChange(_:)), for: .editingChanged)

    keyboardAttach$
      .subscribe(onNext: {[weak self] info in
        self?.onKeyboardHeightDidChange(info: info)
      })
      .disposed(by: disposeBag)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hideNavigationBar()
  }

  func hideNavigationBar() {
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  @objc func login() {
    authState.eitherL(
      notSelected: {
        authState = .login
    },
      selected: { _ in
        guard let email = emailTextField.text, let password = passwordTextField.text else {
          return
        }
        self.viewModel.tryLogin(email: email, password: password, onLoginFailed: {[weak self] in
          self?.showErrorMessage(with: NSLocalizedString(
            "Invalid credentials! Please, try again.",
            comment: "Failed login"
          ))
        })

    }
    )
  }

  @objc func signIn() {
    authState.eitherL(
      notSelected: {
        authState = .signIn
    },
      selected: {_ in
        guard let email = emailTextField.text, let password = passwordTextField.text else {
          return
        }
        self.viewModel.trySignUp(email: email, password: password, onSignUpFailed: { [weak self] message in
          self?.showErrorMessage(with: message)
        })

    }
    )
  }

  @objc func onBack() {
    authState = .notSelected
    emailTextField.resignFirstResponder()
    passwordTextField.resignFirstResponder()

  }

  @objc func hideErrorMessage() {
    messageView?.removeFromSuperview()
    messageView = nil
  }

  func showErrorMessage(with text: String) {
    messageView = setupErrorMessageView(with: text)

    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
      if self?.messageView != nil {
        UIView.animate(
          withDuration: 0.3,
          animations: {
            self?.messageView?.alpha = 0
        },
          completion: { _ in
            self?.hideErrorMessage()
        }
        )
      }
    }
  }

  private func onKeyboardHeightDidChange(info: KeyboardAttachInfo?) {
    bottomConstraintForKeyboard?.constant = info.fold(
      none: -loginButtonBottomPadding,
      some: { -($0.height + 40) }
    )
  }
}

extension LoginViewController {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()

    if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
      return false
    }
    if authState == .login {
      login()
    } else {
      signIn()
    }

    return true
  }

  @objc func emailDidChange(_ textField: TextFieldWithShadow) {
    guard let text = textField.text else {
      return
    }
    isEmailValid = viewModel.validateEmail(text: text)
    checkButtonState(for: authState)
  }

  @objc func passwordDidChange(_ textField: TextFieldWithShadow) {
    guard let text = textField.text else {
      return
    }
    isPasswordValid = viewModel.validatePassword(text: text)
    checkButtonState(for: authState)
  }

  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {

    guard let text = textField.text else {
      return true
    }

    let isValid = textField == emailTextField
      ? viewModel.validateEmail(text: text)
      : viewModel.validatePassword(text: text)

    guard let loginTextField = textField as? TextFieldWithShadow else {
      return true
    }

    loginTextField.isValid = isValid
    return true
  }

  func isAllTextFieldsValid() -> Bool {
    return isEmailValid && isPasswordValid
  }

  func checkButtonState(for state: AuthState) {
    switch state {
    case .notSelected:
      return
    case .login:
      loginButton.isEnabled = isAllTextFieldsValid()
    case .signIn:
      signInButton.isEnabled = isAllTextFieldsValid()
    }
  }
}

extension LoginViewController {

  func animateTextFields(forState state: AuthState) {

    if state != .notSelected {
      textFieldWrapperView.isHidden = false
    }
    self.textFieldsTopLayoutConstraint?.constant = state.either(notSelected: 190, selected: 150)

    UIView.animate(
      withDuration: 0.4,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0.75,
      options: .allowUserInteraction,
      animations: {
        self.view.layoutIfNeeded()
        self.textFieldWrapperView.alpha = state.either(notSelected: 0, selected: 1)
    },
      completion: { _ in
        state.eitherL(
          notSelected: { self.textFieldWrapperView.isHidden = true },
          selected: { _ in self.emailTextField.becomeFirstResponder() }
        )
    }
    )
  }

  func toggleSignInButton(state: AuthState) {
    signInButton.isHidden = state == .login
  }

  func toggleLoginButton(state: AuthState) {

    if state == .login || authState == .login {
      return
    }

    loginButton.isHidden = state != .notSelected
    signInButtonTopLayoutConstraint?.constant = state.either(
      notSelected: 40,
      selected: -40
    )
    UIView.animate(
      withDuration: 0.4,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0.75,
      options: .allowUserInteraction,
      animations: { self.view.layoutIfNeeded() },
      completion: nil
    )
  }

  func toggleBackButton(state: AuthState) {
    backButton.isEnabled = state != .notSelected
    backButton.alpha = state.either(notSelected: 0, selected: 1)
  }
}

enum AuthState {
  case notSelected, login, signIn

  func either<Result>(notSelected: Result, selected: Result) -> Result {
    if self == .notSelected {
      return notSelected
    }
    return selected
  }

  func eitherL<Result>(notSelected: () -> Result, selected: (AuthState) -> Result) -> Result {
    if self == .notSelected {
      return notSelected()
    }
    return selected(self)
  }
}
