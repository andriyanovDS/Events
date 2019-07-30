//
//  UserDetailsSectionView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

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

    private func sutupLabel(with text: String) {
        label.text = text
        label.textColor = UIColor.gray800()
        label.font = UIFont(name: "CeraPro-Medium", size: 16)
        label.numberOfLines = 1

        self.addSubview(label)
        sutupLabelConstraints()
    }

    private func setupChildView(_ childView: UIView) {
        self.addSubview(childView)
        setupChildViewConstraints(childView)
    }

    private func sutupLabelConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
    }

    private func setupChildViewConstraints(_ childView: UIView) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 7),
            childView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            childView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
    }
}
