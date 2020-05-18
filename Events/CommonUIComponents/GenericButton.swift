//
//  GenericButton.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class GenericButton<T>: UIButtonScaleOnPress {
  var value: T
  var onTouch: ((T) -> Void)?

  init(value: T) {
    self.value = value
    super.init(frame: CGRect.zero)

    self.addTarget(self, action: #selector(handleTouchInside), for: .touchUpInside)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func handleTouchInside() {
    onTouch?(value)
  }
}
