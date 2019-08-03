//
//  TextFieldWithBottomLine.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class TextFieldWithBottomLine: UITextField {
    var bottomBorder: CALayer!

    var defaultBottomLineColor: CGColor = UIColor.gray200().cgColor {
        didSet {
            bottomBorder.backgroundColor = defaultBottomLineColor
        }
    }

    override var bounds: CGRect {
        didSet {
            setupLeftView()
            bottomBorder = self.addBorder(
                toSide: .bottom,
                withColor: defaultBottomLineColor,
                andThickness: 1.0
            )
        }
    }

    var isValid: Bool = false {
        willSet (nextValue) {
            if nextValue == isValid {
                return
            }
            self.bottomBorder.backgroundColor = nextValue
                ? defaultBottomLineColor
                : UIColor.red.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        autocorrectionType = .no
        autocapitalizationType = .none
    }

    private func setupLeftView() {
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: bounds.height))
        leftView.backgroundColor = .clear
        self.leftView = leftView
        leftViewMode = .always
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        bottomBorder.backgroundColor = UIColor.blue().cgColor
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        bottomBorder.backgroundColor = defaultBottomLineColor
        return super.resignFirstResponder()
    }
}
