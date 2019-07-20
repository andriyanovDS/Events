//
//  UIButtonScaleOnPress.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class UIButtonScaleOnPress: UIButton {

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.7 : 1
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
}
