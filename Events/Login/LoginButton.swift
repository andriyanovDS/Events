//
//  LoginButton.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class LoginButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1
            UIView.animate(
                withDuration: 0.6,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0.75,
                options: .allowUserInteraction,
                animations: {
                    if self.isHighlighted {
                        self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                    } else {
                        self.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }
                },
                completion: nil
            )
        }
    }

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
