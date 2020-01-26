//
//  ViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Hero
import Stevia

class RootScreenViewController: UIViewController, ViewModelBased {
  var viewModel: RootScreenViewModel! {
    didSet {
      viewModel.onChangeLocation = onChangeLocation
      viewModel.delegate = self
    }
  }
  var rootScreenView: RootScreenView?
  let searchBar = SearchBarViewController(nibName: nil, bundle: nil)

  override func viewDidLoad() {
    super.viewDidLoad()

    initializeUserLocation()
    setupView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  @objc func openCalendar() {
    viewModel.openCalendar()
  }
  
  @objc func openLocationSearch() {
    viewModel.openLocationSearch()
  }

  private func setupView() {
    rootScreenView = RootScreenView(searchBarView: searchBar.view)
    view = rootScreenView
    rootScreenView?.datesButton.addTarget(
      self,
      action: #selector(openCalendar),
      for: .touchUpInside
    )
    rootScreenView?.locationButton.addTarget(
      self,
      action: #selector(openLocationSearch),
      for: .touchUpInside
    )
  }
}

extension RootScreenViewController: RootScreenViewModelDelegate {
  func onChangeLocation(locationName: String) {
    rootScreenView?.setLocationButtonLabelText(locationName)
  }

  func onDatesDidChange(dates: String?) {
    rootScreenView?.setDatesButtonLabelText(dates)
  }
}
