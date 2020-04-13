//
//  LoginView.swift
//  Events
//
//  Created by Dmitry on 23.02.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import RxSwift

class LoginView: UIView {
  var emailTextField: UITextField?
  var passwordTextField: UITextField?
  var backButton: UIButton?
	let loginButton = ButtonScale()
	let signInButton = ButtonScale()
	private var messageView: UIView?
	private let buttonsContainer = UIView()
  private var textFieldsWrapperView: UIView?
	private let disposeBag = DisposeBag()
	
	init() {
		super.init(frame: CGRect.zero)
		setupView()
		keyboardAttachWithDebounce$
			.subscribe(onNext: {[weak self] info in
				self?.onKeyboardHeightDidChange(info: info)
			})
			.disposed(by: disposeBag)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func showErrorMessage(with text: String) {
		if messageView != nil { return }
		setupErrorMessageView(with: text)
		
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

  func showTextFields() {
    let textFieldsWrapperView = UIView()
		let emailTextField = LoginTextField(type: .email)
		let passwordTextField = LoginTextField(type: .password)

    let backButton = UIButton()
    backButton.setImage(
      UIImage(
        from: .materialIcon,
        code: "arrow.back",
        textColor: .fontLabel,
        backgroundColor: .clear,
        size: CGSize(width: 40, height: 40)
      ),
      for: .normal
    )
    textFieldsWrapperView.alpha = 0
    sv(textFieldsWrapperView.sv(backButton, emailTextField, passwordTextField))
    backButton.top(50).left(25)
    textFieldsWrapperView.left(0).right(0).top(0)
    emailTextField
      .top(UIScreen.main.bounds.height * 0.3)
      .centerHorizontally()
      .width(300)
      .height(45)
    passwordTextField.left(0).right(0)
    equal(sizes: [emailTextField, passwordTextField])
    passwordTextField.centerHorizontally()
    passwordTextField.Top == emailTextField.Bottom + 25
    textFieldsWrapperView.Bottom == passwordTextField.Bottom

    self.backButton = backButton
    self.emailTextField = emailTextField
    self.passwordTextField = passwordTextField
    self.textFieldsWrapperView = textFieldsWrapperView

    animateTextFields(onComplete: { _ in
      emailTextField.becomeFirstResponder()
    })
  }

  func hideTextFields() {
    emailTextField?.resignFirstResponder()
    passwordTextField?.resignFirstResponder()
    animateTextFields(onComplete: {[weak self] _ in
      self?.passwordTextField?.removeFromSuperview()
      self?.emailTextField?.removeFromSuperview()
      self?.backButton?.removeFromSuperview()
      if self?.messageView != nil {
        self?.hideErrorMessage()
      }
    })
  }

  func hideButton(for state: AuthState) {
    if state == .notSelected { return }
    let animatedButton = state == .login
      ? signInButton
      : loginButton

    loginButton.isEnabled = false
    signInButton.isEnabled = false
    UIView.animate(withDuration: 0.3, animations: {
      animatedButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      animatedButton.alpha = 0
    })
  }

  func showButton(prevState: AuthState) {
    if prevState == .notSelected { return }
    let animatedButton = prevState == .login
      ? signInButton
      : loginButton
    signInButton.isEnabled = true
    loginButton.isEnabled = true
    UIView.animate(withDuration: 0.3, animations: {
      animatedButton.transform = .identity
      animatedButton.alpha = 1
    })
  }

  private func animateTextFields(onComplete: ((Bool) -> Void)?) {
    guard let view = textFieldsWrapperView else { return }

    if view.alpha == 1 {
      UIView.animate(withDuration: 0.3, animations: {
        view.alpha = 0
      }, completion: onComplete)
      return
    }
    UIView.animate(withDuration: 0.3, animations: {
       view.alpha = 1
    }, completion: onComplete)
  }
	
	@objc private func hideErrorMessage() {
		messageView?.removeFromSuperview()
		messageView = nil
	}
	
	private func setupErrorMessageView(with text: String) {
    guard let textFieldsWrapperView = textFieldsWrapperView else { return }
		let messageView = UIView()
    messageView.layer.cornerRadius = 7
    messageView.backgroundColor = .destructive
    addShadow(view: messageView, radius: 7, color: .black)
			
    let label = UILabel()
    label.text = text
    label.textColor = .fontLabel
    label.font = FontStyle.medium.font(size: 16)
    label.numberOfLines = 3
    label.lineBreakMode = .byWordWrapping
			
    let closeButton = UIButton()
    let image = UIImage(
      from: .materialIcon,
      code: "close",
      textColor: .fontLabel,
      backgroundColor: .clear,
      size: CGSize(width: 20, height: 20)
      )
    closeButton.setImage(
      image,
      for: .normal
      )
    closeButton.addTarget(self, action: #selector(hideErrorMessage), for: .touchUpInside)
    sv(messageView.sv([label, closeButton]))
    messageView.Top == textFieldsWrapperView.Bottom + 20
    messageView.width(300).centerHorizontally()
    label.left(10).right(30).top(10)
    messageView.Bottom == label.Bottom - 10
    closeButton.right(10).top(5)
    self.messageView = messageView
	}
	
	private func setupView() {
    backgroundColor = .background
		styleText(
      button: loginButton,
      text: NSLocalizedString("Log in", comment: "Log in"),
      size: 20,
      color: .blueButtonFont,
      style: .medium
			)
		styleText(
			button: signInButton,
			text: NSLocalizedString("Sign in", comment: "Sign in"),
			size: 20,
			color: .grayButtonLightFont,
			style: .medium
			)
		let buttonEdgeInset = UIEdgeInsets(
			top: 12,
			left: 12,
			bottom: 12,
			right: 12
		)
		signInButton.backgroundColor = .grayButtonBackground
		signInButton.contentEdgeInsets = buttonEdgeInset
    loginButton.backgroundColor = .blueButtonBackground
		loginButton.contentEdgeInsets = buttonEdgeInset
		sv(buttonsContainer.sv(signInButton, loginButton))
    setupButtonsConstraints()
	}
	
	private func setupButtonsConstraints() {
		buttonsContainer.bottom(100).left(0).right(0)
		loginButton.width(250)
    loginButton.centerHorizontally()
    signInButton.centerHorizontally().bottom(0)
		equal(sizes: [loginButton, signInButton])
		loginButton.Bottom == signInButton.Top - 25
		buttonsContainer.Top == loginButton.Top
	}
	
	private func onKeyboardHeightDidChange(info: KeyboardAttachInfo?) {
    let bottomConstraint = info
      .map { v -> CGFloat in
				if signInButton.alpha != 0 {
					return v.height + 25.0
				}
				return v.height - loginButton.bounds.height
			}
		.getOrElse(result: 100.0)
		UIView.animate(
      withDuration: info?.duration ?? 0.2,
      animations: {
				self.buttonsContainer.bottomConstraint?.constant = -bottomConstraint
				self.layoutIfNeeded()
      })
  }
}
