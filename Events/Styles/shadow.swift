//
//  shadow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 11/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

func addShadow(view: UIView, radius: CGFloat, color: UIColor = .fontLabel, opacity: Float = 0.3) {
  view.layer.shadowRadius = radius
  view.layer.shadowOpacity = opacity
  view.layer.shadowColor = color.cgColor
  view.layer.shadowOffset = .zero
  view.layer.masksToBounds = false
}
