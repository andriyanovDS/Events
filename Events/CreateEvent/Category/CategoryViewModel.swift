//
//  CategoryViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import RxFlow
import RxCocoa

class CategoryViewModel: Stepper {
  weak var delegate: CategoryViewModelDelegate?
  let steps = PublishRelay<Step>()
  var category: CategoryId?

  func openNextScreen() {
    guard let category = self.category else { return }
    delegate?.onResult(category)
    steps.accept(CreateEventStep.categoryDidComplete)
  }
}

protocol CategoryViewModelDelegate: class {
  var onResult: ((CategoryId) -> Void)! { get }
}
