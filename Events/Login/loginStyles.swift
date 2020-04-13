//
//  loginStyles.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/02/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

func loginTextFieldStyle(_ view: UITextField) {
  view.style({ v in
    v.setupLeftView(width: 15)
    v.contentHorizontalAlignment = .left
    v.layer.cornerRadius = 15
    v.backgroundColor = UIColor.textField
  })
}
