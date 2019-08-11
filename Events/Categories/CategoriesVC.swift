//
//  CategoriesView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class CategoriesViewController {
  let view = UIScrollView()
  private let viewModel = CategoriesViewModel()
  
  init() {
    setupScrollView()
    setupCategories()
  }
  
  @objc func onSelectCategory(_ button: UIButton) {
    
  }
  
  func setupScrollView() {
    view.showsHorizontalScrollIndicator = false
  }
  
  func setupCategories() {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.distribution = .fillEqually
    stackView.spacing = 10
    
    viewModel.categories.forEach { setupCategoryView(stackView: stackView, category: $0) }
    
    view.addSubview(stackView)
    
    setupCategoriesStackViewConstraints(stackView: stackView)
  }
  
  func setupCategoryView(stackView: UIStackView, category: Category) {
    let wrapperView = UIView()
    let categoryButton = UIButtonScaleOnPress()
    categoryButton.backgroundColor = .white
    categoryButton.setTitle(category.name, for: .normal)
    categoryButton.setTitleColor(UIColor.gray600(), for: .normal)
    categoryButton.titleLabel?.lineBreakMode = .byWordWrapping
    categoryButton.titleLabel?.textAlignment = .left
    categoryButton.contentVerticalAlignment = .bottom
    categoryButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
    categoryButton.layer.cornerRadius = 7
    categoryButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 8, bottom: 7, right: 12)
    
    categoryButton.addTarget(self, action: #selector(onSelectCategory(_:)), for: .touchUpInside)
    wrapperView.addSubview(categoryButton)
    stackView.addArrangedSubview(wrapperView)
    setupCateroryWrapperViewConstraints(view: wrapperView)
    setupCateroryButtonConstraints(wrapperView: wrapperView, button: categoryButton)
    
    addShadow(view: categoryButton, radius: 3, color: .black)
  }
  
  func setupCategoriesStackViewConstraints(stackView: UIView) {
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
      stackView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -10)
      ])
  }
  
  func setupCateroryWrapperViewConstraints(view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      view.widthAnchor.constraint(equalToConstant: 140),
      view.heightAnchor.constraint(equalToConstant: 60)
      ])
  }
  
  func setupCateroryButtonConstraints(wrapperView: UIView, button: UIView) {
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
      button.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
      button.topAnchor.constraint(equalTo: wrapperView.topAnchor),
      button.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor)
      ])
  }
}
