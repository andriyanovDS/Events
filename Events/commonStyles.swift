//
//  commonStyles.swift
//  Events
//
//  Created by Дмитрий Андриянов on 06/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

func shadowStyle(view: UIView, radius: CGFloat, color: UIColor) {
    view.layer.shadowRadius = radius
    view.layer.shadowOpacity = 0.3
    view.layer.shadowColor = color.cgColor
    view.layer.shadowOffset = .zero
    view.layer.masksToBounds = false
}
