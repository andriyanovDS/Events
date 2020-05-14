//
//  CategoryViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import RxFlow
import RxCocoa

class CategoryViewModel: Stepper, ResultProvider {
  let steps = PublishRelay<Step>()
  var category: CategoryId?
  let onResult: ResultHandler<CategoryId>

  init(onResult: @escaping ResultHandler<CategoryId>) {
    self.onResult = onResult
  }

  func openNextScreen() {
    guard let category = self.category else { return }
    onResult(category)
    steps.accept(CreateEventStep.categoryDidComplete)
  }
}
