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
import CoreLocation

class RootScreenViewController: UIViewController, ViewModelBased {
  var viewModel: RootScreenViewModel! {
    didSet {
      viewModel.onChangeLocation = onChangeLocation
      viewModel.delegate = self
    }
  }
  private var rootScreenView: RootScreenView?
  private let locationManager = CLLocationManager()
  private let searchBar = SearchBarViewController(nibName: nil, bundle: nil)

  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.delegate = self
    setupView()
    initializeUserLocation()
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

extension RootScreenViewController: CLLocationManagerDelegate {
  func initializeUserLocation() {
    let status = CLLocationManager.authorizationStatus()
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      locationManager.startUpdatingLocation()
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    default:
      rootScreenView?.setLocationButtonLabelText(nil)
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    if status == .denied || status == .restricted {
      rootScreenView?.setLocationButtonLabelText(nil)
      return
    }
    manager.startUpdatingLocation()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let coordinates: CLLocation = locations[0]
    manager.stopUpdatingLocation()
    onChangeUserLocation(coordinate: coordinates.coordinate)
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
