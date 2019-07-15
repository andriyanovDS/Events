//
//  SearchBarViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 05/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import SwiftIconFont

class SearchBarViewController: UIViewController, UITextFieldDelegate {

    weak var delegate: SearchBarDelegate?

    let textField = UITextField()
    private let contentHeight: CGFloat = 40.0
    private var textFieldTrailingConstraint: NSLayoutConstraint?
    private let textFieldLeftViewStub = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
    private let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField()
    
        textField.delegate = self
        cancelButton.addTarget(self, action: #selector(cancelTextField), for: .touchUpInside)
    }
    
    private func animateTextFieldTrailingConstraint(value: CGFloat, onClomplete: ((Bool) -> Void)?) {
        textFieldTrailingConstraint?.constant = value
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.75,
            options: .curveEaseIn,
            animations: { self.view.layoutIfNeeded() },
            completion: onClomplete
        )
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.leftView = textFieldLeftViewStub
        animateTextFieldTrailingConstraint(
            value: -90,
            onClomplete: { [weak self] finished in
                if finished {
                    self?.cancelButton.isHidden = false
                    self?.delegate?.searchBarDidActivate()
                }
            }
        )
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cancelTextField()
        return true
    }
    
    @objc func cancelTextField() {
        textField.resignFirstResponder()
        setupSearchIcon()
        animateTextFieldTrailingConstraint(value: -20, onClomplete: {[weak self] _ in
            self?.delegate?.searchBarDidCancel()
        })
        cancelButton.isHidden = true
    }
    
}

extension SearchBarViewController {

    private func setupTextField() {
        
        textField.isEnabled = true
        textField.isUserInteractionEnabled = true
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.gray,
                NSAttributedString.Key.font: UIFont.init(
                    name: "CeraPro-Medium",
                    size: 18
                ) ?? UIFont.systemFont(ofSize: 18)
            ]
        )
        
        textField.layer.cornerRadius = 3
        textField.backgroundColor = .white
        
        textField.addShadow(radius: 7, color: .black)
        
        view.addSubview(textField)
        setupCancelButton()
        setupSearchIcon()
        setupTextFieldConstraints()
    }
    
    private func setupSearchIcon() {
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: contentHeight))
        let image = UIImage(
            from: .materialIcon,
            code: "search",
            textColor: .black,
            backgroundColor: .clear,
            size: CGSize(width: 30, height: 30)
        )
        let imageView = UIImageView(frame: CGRect(x: 10, y: 5, width: 30, height: 30))
        outerView.addSubview(imageView)
        textField.leftView = outerView
        textField.leftViewMode = .always
        imageView.image = image
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle("Закрыть", for: .normal)
        cancelButton.setTitleColor(.gray, for: .normal)
        cancelButton.titleLabel?.font = UIFont.init(name: "CeraPro-Medium", size: 14)
        
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 12, right: 0)
        view.addSubview(cancelButton)
        cancelButton.isHidden = true
        setupCancelButtonConstraints()
    }
    
    private func setupCancelButtonConstraints() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    private func setupTextFieldConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textFieldTrailingConstraint = textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        textFieldTrailingConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            textField.heightAnchor.constraint(equalToConstant: contentHeight),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30)
        ])
    }
}
