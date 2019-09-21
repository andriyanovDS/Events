//
//  ViewModelBased.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Foundation

protocol ViewModelServices {
  associatedtype Services
  var services: Services! { get set }
}

protocol ViewModelBased {
  associatedtype ViewModelType
  var viewModel: ViewModelType! { get set }
}

extension ViewModelBased where Self: UIViewController {
  static func instantiate<ViewModelType> (
    with viewModel: ViewModelType
  ) -> Self where ViewModelType == Self.ViewModelType {
    var viewController = Self.init()
    viewController.viewModel = viewModel
    return viewController
  }
}
