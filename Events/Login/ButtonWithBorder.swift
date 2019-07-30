//
//  LoginButton.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class ButtonWithBorder: UIButtonScaleOnPress {

    override var isEnabled: Bool {
        didSet {
            self.alpha = isEnabled ? 1 : 0.5
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        layer.cornerRadius = 4
        layer.borderWidth = 1
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center
        titleLabel?.font = UIFont.init(name: "CeraPro-Medium", size: 18)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
