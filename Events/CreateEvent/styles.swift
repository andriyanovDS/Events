//
//  styles.swift
//  Events
//
//  Created by Дмитрий Андриянов on 22/02/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

func selectButtonStyle(_ view: UIButton) -> UIButton {
  view.style { v in
    v.contentEdgeInsets = UIEdgeInsets(
      top: 12,
      left: 10,
      bottom: 12,
      right: 10
    )
    v.contentHorizontalAlignment = .left
    v.layer.cornerRadius = 15
    v.backgroundColor = .textField
  }
  return view
}

func selectTextFieldStyle(_ view: UITextField) -> UITextField {
  view.style { v in
    v.setupLeftView(width: 15)
    v.contentHorizontalAlignment = .left
    v.layer.cornerRadius = 15
    v.backgroundColor = .textField
  }
  return view
}
