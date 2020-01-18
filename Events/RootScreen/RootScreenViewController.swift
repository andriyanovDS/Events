//
//  ViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class RootScreenViewController: UIViewController, ViewModelBased, RootScreenViewModelDelegate {
  var viewModel: RootScreenViewModel! {
    didSet {
      viewModel.onChangeLocation = onChangeLocation
      viewModel.delegate = self
    }
  }
  
  let titleLabel = UILabel()
  let categoriesView = CategoriesViewController()
  let locationButton = FilterButton()
  let datesButton = FilterButton()
  let searchBar = SearchBarViewController(nibName: nil, bundle: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()

    initializeUserLocation()
    setupView()
    view.addSubview(searchBar.view)
    view.addSubview(categoriesView.view)
    setupSearchBarViewConstraints()
    setupButtonsContainer()
    setupTitleLabel()
    setupCategoryViewConstraints()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    hideNavigationBar()
  }
  
  @objc func openCalendar() {
    viewModel.openCalendar()
  }
  
  @objc func openLocationSearch() {
    viewModel.openLocationSearch()
  }
  
  func onChangeLocation(locationName: String) {
    locationButton.setTitle(locationName, for: .normal)
  }
  
  func onDatesDidChange(dates: String?) {
    let buttonTitle = dates
    if buttonTitle == datesButton.title(for: .normal) {
      return
    }
    
    if buttonTitle == nil {
      datesButton.isFilterEmpty = true
      datesButton.layer.borderWidth = 1
      datesButton.setTitleColor(UIColor.gray600(), for: .normal)
      datesButton.backgroundColor = .white
    } else {
      datesButton.isFilterEmpty = false
      datesButton.layer.borderWidth = 0
      datesButton.setTitleColor(.white, for: .normal)
      datesButton.backgroundColor = UIColor.lightBlue()
    }
    datesButton.setTitle(buttonTitle ?? NSLocalizedString("Dates", comment: "Select calendar dates label"), for: .normal)
  }
}

extension RootScreenViewController {
  
  func hideNavigationBar() {
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  func setupView() {
    view.backgroundColor = .white
  }
  
  func setupSearchBarViewConstraints() {
    guard let searchBar = searchBar.view else {
      return
    }
    
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
      searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
      ])
  }
  
  func setupButtonsContainer() {
    let container = UIView()
    view.addSubview(container)
    setupButtonsContainerConstraints(containerView: container)
    setupDatesButton(containerView: container)
    setupLocationButton(containerView: container)
    
  }
  
  func setupDatesButton(containerView: UIView) {
    datesButton.setTitle("Дата", for: .normal)
    datesButton.addTarget(self, action: #selector(openCalendar), for: .touchUpInside)
    containerView.addSubview(datesButton)
    setupDatesButtonConstraints(containerView: containerView)
  }
  
  func setupLocationButton(containerView: UIView) {
    locationButton.addTarget(self, action: #selector(openLocationSearch), for: .touchUpInside)
    containerView.addSubview(locationButton)
    setupLocationButtonConstraints(containerView: containerView)
  }
  
  func setupTitleLabel() {
    titleLabel.text = NSLocalizedString("Choose your next experience", comment: "Home screen title")
    titleLabel.numberOfLines = 2
    titleLabel.font = UIFont.init(name: "CeraPro-Bold", size: 22)
    titleLabel.textAlignment = .left
    titleLabel.textColor = UIColor.gray900()
    view.addSubview(titleLabel)
    
    setupTitleLabelConstraints()
  }
  
  func setupButtonsContainerConstraints(containerView: UIView) {
    guard let saerchBarView = searchBar.view else {
      return
    }
    containerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      containerView.topAnchor.constraint(equalTo: saerchBarView.bottomAnchor, constant: 7),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      containerView.heightAnchor.constraint(equalToConstant: 30)
      ])
  }
  
  func setupDatesButtonConstraints(containerView: UIView) {
    datesButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      datesButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
      ])
  }
  
  func setupTitleLabelConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: datesButton.bottomAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
      ])
  }
  
  func setupLocationButtonConstraints(containerView: UIView) {
    locationButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      locationButton.leadingAnchor.constraint(equalTo: datesButton.trailingAnchor, constant: 8)
      ])
  }
  
  func setupCategoryViewConstraints() {
    let categoryView = self.categoriesView.view
    categoryView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      categoryView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
      categoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      categoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
      categoryView.heightAnchor.constraint(equalToConstant: 70)
      ])
  }
}

class FilterButton: UIButton {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .white
    self.layer.cornerRadius = 4
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.gray400().cgColor
    self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    self.setTitleColor(UIColor.gray600(), for: .normal)
    self.titleLabel?.font = UIFont.init(name: "CeraPro-Medium", size: 12)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var isFilterEmpty: Bool = true
  
  override var isHighlighted: Bool {
    didSet {
      if isFilterEmpty {
        backgroundColor = isHighlighted ? UIColor.gray200() : UIColor.white
      } else {
        backgroundColor = isHighlighted ? UIColor.blue() : UIColor.lightBlue()
      }
    }
  }
}
