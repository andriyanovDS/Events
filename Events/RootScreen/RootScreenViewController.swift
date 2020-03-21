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
import AsyncDisplayKit

class RootScreenViewController: ASViewController<RootScreenNode>, ViewModelBased {
  var viewModel: RootScreenViewModel! {
    didSet {
      viewModel.delegate = self
    }
  }
  private let locationManager = CLLocationManager()

  init() {
    super.init(node: RootScreenNode())
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.delegate = self
    node.eventTableNode.dataSource = self
    initializeUserLocation()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  private func setupView() {
    node.eventTableNode.dataSource = self
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
      return
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    if status == .denied || status == .restricted {
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
  func onAppendEventList(_ newData: [Event]) {
    node.eventTableNode.reloadData()
  }
}

extension RootScreenViewController: ASTableDataSource {
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return viewModel.eventList.count
  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let event = viewModel.eventList[indexPath.item]
    guard let author = viewModel.author(id: event.author) else {
      fatalError("Event must have author")
    }
    let block = { () -> EventCellNode in
      let cell = EventCellNode(event: event, author: author)
      cell.delegate = self.viewModel
      return cell
    }
    return block
  }
}
