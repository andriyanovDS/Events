//
//  CategoryViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, ViewModelBased {
  var viewModel: CategoryViewModel!
  private var categoryView: CategoriesView?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  private func setupView() {
    let categoryView = CategoriesView()
    categoryView.delegate = self
    view = categoryView
    self.categoryView = categoryView
  }
}

extension CategoryViewController: CategoriesViewDelegate {
  func openNextScreen() {
    viewModel.openNextScreen()
  }

  func onSelect(category: CategoryId) {
    viewModel.category = category
  }
}
