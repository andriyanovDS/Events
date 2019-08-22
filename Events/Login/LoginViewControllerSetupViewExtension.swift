//
//  LoginViewControllerSetupViewExtenstion.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

extension LoginViewController {
  
  func setupView() {
    view.backgroundColor = .lightBlue()
    
    setupLoginButton()
    setupSignInBuntton()
    setupTextFieldWrapperView()
  }
  
  func setupLoginButton() {
    loginButton.layer.borderColor = UIColor.red.cgColor
    loginButton.setTitleColor(.red, for: .normal)
    loginButton.setTitle("Войти", for: .normal)
    loginButton.titleLabel?.font = UIFont(name: "CeraPro-Medium", size: 20)
    loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
    
    view.addSubview(loginButton)
    
    setupLoginButtonConstraints()
  }
  
  func setupSignInBuntton() {
    signInButton.setTitleColor(.gray800(), for: .normal)
    signInButton.layer.borderColor = UIColor.gray800().cgColor
    signInButton.setTitle("Зарегистрироваться", for: .normal)
    signInButton.titleLabel?.font = UIFont(name: "CeraPro-Medium", size: 20)
    signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
    
    view.addSubview(signInButton)
    setupSignInBunttonConstraints()
  }
  
  func setupTextFieldWrapperView() {
    textFieldWrapperView.isHidden = true
    textFieldWrapperView.alpha = 0
    view.addSubview(textFieldWrapperView)
    
    setupTextFieldWrapperViewContraints()
    setupEmailTextField()
    setupPasswordTextField()
    setupBackButton()
  }
  
  func setupEmailTextField() {
    emailTextField.attributedPlaceholder = NSAttributedString(
      string: "E-mail",
      attributes: [
        NSAttributedString.Key.foregroundColor: UIColor.gray,
        NSAttributedString.Key.font: UIFont.init(
          name: "CeraPro-Medium",
          size: 18
          ) ?? UIFont.systemFont(ofSize: 14)
      ]
    )
    emailTextField.keyboardType = .emailAddress
    emailTextField.layer.borderWidth = 1
    textFieldWrapperView.addSubview(emailTextField)
    setupEmailTextFieldConstraints()
  }
  
  func setupPasswordTextField() {
    passwordTextField.attributedPlaceholder = NSAttributedString(
      string: "Пароль",
      attributes: [
        NSAttributedString.Key.foregroundColor: UIColor.gray,
        NSAttributedString.Key.font: UIFont.init(
          name: "CeraPro-Medium",
          size: 18
          ) ?? UIFont.systemFont(ofSize: 14)
      ]
    )
    emailTextField.layer.borderWidth = 1
    passwordTextField.keyboardType = .default
    passwordTextField.isSecureTextEntry = true
    
    textFieldWrapperView.addSubview(passwordTextField)
    setupPasswordTextFieldConstraints()
  }
  
  func setupBackButton() {
    backButton.setImage(
      UIImage(
        from: .materialIcon,
        code: "arrow.back",
        textColor: .black,
        backgroundColor: .clear,
        size: CGSize(width: 40, height: 40)
      ),
      for: .normal
    )
    backButton.alpha = 0
    backButton.isEnabled = false
    backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
    
    view.addSubview(backButton)
    setupBackButtonConstraints()
  }
  
  func setupLoginButtonConstraints() {
    loginButton.translatesAutoresizingMaskIntoConstraints = false
    bottomConstraintForKeyboard = loginButton.bottomAnchor.constraint(
      equalTo: view.bottomAnchor,
      constant: -loginButtonBottomPadding
    )
    
    NSLayoutConstraint.activate([
      loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      loginButton.heightAnchor.constraint(equalToConstant: 50),
      loginButton.widthAnchor.constraint(equalToConstant: 250),
      bottomConstraintForKeyboard!
      ])
  }
  
  func setupSignInBunttonConstraints() {
    signInButton.translatesAutoresizingMaskIntoConstraints = false
    signInButtonTopLayoutConstraint = signInButton.topAnchor.constraint(
      equalTo: loginButton.bottomAnchor,
      constant: 40
    )
    NSLayoutConstraint.activate([
      signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      signInButton.heightAnchor.constraint(equalTo: loginButton.heightAnchor),
      signInButton.widthAnchor.constraint(equalTo: loginButton.widthAnchor),
      signInButtonTopLayoutConstraint!
      ])
  }
  
  func setupTextFieldWrapperViewContraints() {
    textFieldWrapperView.translatesAutoresizingMaskIntoConstraints = false
    
    textFieldsTopLayoutConstraint = textFieldWrapperView.topAnchor.constraint(
      equalTo: view.topAnchor,
      constant: 170
    )
    
    NSLayoutConstraint.activate([
      textFieldWrapperView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
      textFieldWrapperView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
      textFieldWrapperView.heightAnchor.constraint(equalToConstant: 130),
      textFieldsTopLayoutConstraint!
      ])
  }
  
  func setupEmailTextFieldConstraints() {
    emailTextField.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      emailTextField.heightAnchor.constraint(equalToConstant: 45),
      emailTextField.leadingAnchor.constraint(equalTo: textFieldWrapperView.leadingAnchor),
      emailTextField.trailingAnchor.constraint(equalTo: textFieldWrapperView.trailingAnchor),
      emailTextField.topAnchor.constraint(equalTo: textFieldWrapperView.topAnchor)
      ])
  }
  
  func setupPasswordTextFieldConstraints() {
    passwordTextField.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      passwordTextField.heightAnchor.constraint(equalToConstant: 45),
      passwordTextField.leadingAnchor.constraint(equalTo: textFieldWrapperView.leadingAnchor),
      passwordTextField.trailingAnchor.constraint(equalTo: textFieldWrapperView.trailingAnchor),
      passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 40)
      ])
  }
  
  func setupBackButtonConstraints() {
    backButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60)
      ])
  }
}

extension LoginViewController {
  
  func setupErrorMessageView(with text: String) -> UIView {
    let messageView = UIView()
    messageView.layer.cornerRadius = 7
    messageView.backgroundColor = UIColor.lightRed()
    shadowStyle(view: messageView, radius: 7, color: .black)
    
    let label = UILabel()
    label.text = text
    label.textColor = UIColor.gray900()
    label.font = UIFont(
      name: "CeraPro-Medium",
      size: 14
    )
    label.numberOfLines = 2
    label.lineBreakMode = .byWordWrapping
    
    let closeButton = UIButton()
    let image = UIImage(
      from: .materialIcon,
      code: "close",
      textColor: UIColor.gray900(),
      backgroundColor: .clear,
      size: CGSize(width: 20, height: 20)
    )
    closeButton.setImage(
      image,
      for: .normal
    )
    closeButton.addTarget(self, action: #selector(hideErrorMessage), for: .touchUpInside)
    
    messageView.addSubview(label)
    messageView.addSubview(closeButton)
    view.addSubview(messageView)
    setupErrorMessageViewConstraints(messageView)
    setupErrorMessageLabelConstraints(messageView: messageView, label: label)
    setupErrorMessageButtonConstraints(messageView: messageView, button: closeButton)
    return messageView
  }
  
  func setupErrorMessageViewConstraints(_ messageView: UIView) {
    messageView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      messageView.topAnchor.constraint(equalTo: textFieldWrapperView.bottomAnchor, constant: 20),
      messageView.leadingAnchor.constraint(equalTo: textFieldWrapperView.leadingAnchor),
      messageView.trailingAnchor.constraint(equalTo: textFieldWrapperView.trailingAnchor)
      ])
  }
  
  func setupErrorMessageLabelConstraints(messageView: UIView, label: UIView) {
    label.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 10),
      label.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: 15),
      label.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -30),
      label.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -10)
      ])
  }
  
  func setupErrorMessageButtonConstraints(messageView: UIView, button: UIView) {
    button.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      button.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 10),
      button.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -10),
      button.heightAnchor.constraint(equalToConstant: 20),
      button.widthAnchor.constraint(equalToConstant: 20)
      ])
  }
}
