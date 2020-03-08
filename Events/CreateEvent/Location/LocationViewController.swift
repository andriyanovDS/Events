//
//  LocationViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 07/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController, ViewModelBased, ScreenWithResult {
  var onResult: ((Geocode) -> Void)!
  var onBackAction: (() -> Void)!
  var viewModel: LocationViewModel! {
    didSet {
      viewModel.delegate = self
    }
  }
  private var locationView: LocationView?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    if isMovingFromParent {
      onBackAction()
    }
  }

  private func setupView() {
    let locationView = LocationView()
    locationView.delegate = self
    if let locationName = viewModel.geocode?.fullLocationName() {
      locationView.setLocationName(locationName)
    }
    view = locationView
    self.locationView = locationView
  }
}

extension LocationViewController: LocationViewDelegate {
  func openChangeLocationModal() {
    viewModel.openLocationSearchBar()
  }

  func openNextScreen() {
    viewModel.openNextScreen()
  }
}

extension LocationViewController: LocationViewModelDelegate {  
  func onLocationNameDidChange(_ name: String) {
    locationView?.setLocationName(name)
  }
}
