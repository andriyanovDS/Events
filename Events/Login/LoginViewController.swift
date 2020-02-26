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
  let backButton = UIButton()
  let textFieldWrapperView = UIView()

  let loginButtonBottomPadding: CGFloat = 200.0

  var isEmailValid: Bool = false
  var isPasswordValid: Bool = false
  private let viewModel: LoginViewModel
	private var loginView: LoginView?

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
      nextState.eitherL(
        notSelected: {
          loginView?.hideTextFields()
          loginView?.showButton(prevState: authState)
        },
        selected: { v in
          setupTextFields()
          loginView?.hideButton(for: v)
        })
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
	
	private func setupView() {
		loginView = LoginView()
		view = loginView
		
		loginView?.loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
		loginView?.signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
  }

  @objc func login() {
    authState.eitherL(
      notSelected: { authState = .login },
      selected: { _ in
        guard let view = loginView else { return }
        guard let email = view.emailTextField?.text, let password = view.passwordTextField?.text else {
          return
        }
        self.viewModel.tryLogin(
          email: email,
          password: password,
          onLoginFailed: {[weak self] in
            self?.loginView?.showErrorMessage(with: NSLocalizedString(
              "Invalid credentials! Please, try again.",
              comment: "Failed login"
            ))
          }
        )
			}
		)
  }

  @objc func signIn() {
    authState.eitherL(
      notSelected: { authState = .signIn },
      selected: { _ in
        guard let view = loginView else { return }
        guard let email = view.emailTextField?.text, let password = view.passwordTextField?.text else {
          return
        }
        self.viewModel.trySignUp(email: email, password: password, onSignUpFailed: { [weak self] message in
          self?.loginView?.showErrorMessage(with: message)
        })
      }
    )
  }

  @objc func onBack() {
    authState = .notSelected
  }

  private func setupTextFields() {
    guard let loginView = self.loginView else { return }
    loginView.showTextFields()
    guard
      let emailTextField = loginView.emailTextField,
      let passwordTextField = loginView.passwordTextField,
      let backButton = loginView.backButton else {
      return
    }
    emailTextField.delegate = self
    passwordTextField.delegate = self
    emailTextField.addTarget(self, action: #selector(emailDidChange(_:)), for: .editingChanged)
    passwordTextField.addTarget(self, action: #selector(passwordDidChange(_:)), for: .editingChanged)
    backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
  }
}

extension LoginViewController {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()

    if textField == loginView?.emailTextField {
      loginView?.passwordTextField?.becomeFirstResponder()
      return false
    }
    if authState == .login {
      login()
    } else {
      signIn()
    }

    return true
  }

  @objc func emailDidChange(_ textField: LoginTextField) {
    guard let text = textField.text else {
      return
    }
    isEmailValid = viewModel.validateEmail(text: text)
    attemptToChangeButtonState(for: authState)
		if !textField.isValid {
			textField.isValid = isEmailValid
		}
  }

  @objc func passwordDidChange(_ textField: LoginTextField) {
    guard let text = textField.text else {
      return
    }
    isPasswordValid = viewModel.validatePassword(text: text)
    attemptToChangeButtonState(for: authState)
		
		if !textField.isValid {
			textField.isValid = isPasswordValid
		}
  }

  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		guard let text = textField.text else {
      return true
    }

    let isValid = textField == loginView?.emailTextField
      ? viewModel.validateEmail(text: text)
      : viewModel.validatePassword(text: text)

    guard let loginTextField = textField as? LoginTextField else {
      return true
    }

    loginTextField.isValid = isValid
		if isValid && loginTextField.type == .password {
			login()
		}
		return true
  }

  func isAllTextFieldsValid() -> Bool {
    return isEmailValid && isPasswordValid
  }

  func attemptToChangeButtonState(for state: AuthState) {
    switch state {
    case .notSelected:
      return
    case .login:
      loginView?.loginButton.isEnabled = isAllTextFieldsValid()
    case .signIn:
      loginView?.signInButton.isEnabled = isAllTextFieldsValid()
    }
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
