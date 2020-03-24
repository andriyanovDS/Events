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
import Promises
import CoreLocation
import AsyncDisplayKit

class RootScreenViewController: ASViewController<RootScreenNode>, ViewModelBased, EventCellNodeDelegate {
  var viewModel: RootScreenViewModel! {
    didSet {
      viewModel.delegate = self
    }
  }
  private let locationManager = CLLocationManager()
  let loadUserAvatar: (_: String) -> Promise<UIImage>
  let loadEventImage: (_: String) -> Promise<UIImage>

  init() {
    loadUserAvatar = memoize(callback: { (v: String) -> Promise<UIImage> in
      InternalImageCache.shared.loadImage(by: v)
        .then(on: .global()) { image -> UIImage in
          let size = EventCellNode.Constants.authorImageSize
          let renderer = UIGraphicsImageRenderer(size: size)
          let resultImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
          }
          return resultImage.makeRoundedImage(size: size, radius: size.width / 2.0)
        }
    })

    loadEventImage = memoize(callback: { (url: String) -> Promise<UIImage> in
      InternalImageCache.shared.loadImage(by: url)
      .then(on: .global()) {image -> UIImage in
        let imageSize = EventCellNode.Constants.eventImageSize
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(
          x: 0, y: 0, width: imageSize.width, height: imageSize.height
        ))
        let size = CGSize(width: rect.width, height: rect.height)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
      }
    })

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
    node.eventTableNode.delegate = self
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
    let block = {() -> EventCellNode in
      let cell = EventCellNode(event: event, author: author)
      cell.delegate = self
      return cell
    }
    return block
  }
}

extension RootScreenViewController: ASTableDelegate {
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableNode.nodeForRow(at: indexPath) as? EventCellNode else {
      return
    }
    viewModel.openEvent(at: indexPath.item, sharedImage: cell.eventImageNode.image)
  }
}
