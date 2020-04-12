//
//  LocationSearchViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 14/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa

class LocationSearchViewController: UIViewControllerWithActivityIndicator, ViewModelBased {
	var viewModel: LocationSearchViewModel! {
		didSet {
			viewModel.delegate = self
		}
	}
	private let disposeBag = DisposeBag()
	private var locationSearchView: LocationSearchView?
	private var locationManager: CLLocationManager?
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
		initializeUserLocation()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    setFocusOnTextField()
  }
  
  func searchBarDidCancel() {
    viewModel.cancelScreen()
  }

  private func setFocusOnTextField() {
    locationSearchView?.textField.becomeFirstResponder()
  }
	
	private func setupView() {
		let locationSearchView = LocationSearchView()
		
		hero.isEnabled = true
		locationSearchView.hero.modifiers = [.fade, .translate(y: 100)]
		
		locationSearchView.predictionsTableView.register(
			LocationCell.self,
			forCellReuseIdentifier: LocationCell.reuseIdentifier
		)
		locationSearchView.predictionsTableView.delegate = self
		locationSearchView.predictionsTableView.dataSource = self
		
		locationSearchView.closeButton.rx.tap
			.subscribe(onNext: {[unowned self] _ in self.viewModel.cancelScreen() })
			.disposed(by: disposeBag)
		
		viewModel.register(textField: locationSearchView.textField)
		view = locationSearchView
		self.locationSearchView = locationSearchView
	}
	
	private func initializeUserLocation() {
		let locationManager = CLLocationManager()
		locationManager.requestWhenInUseAuthorization()

		if CLLocationManager.locationServicesEnabled() {
			self.locationManager = locationManager
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.delegate = self
			locationManager.startUpdatingLocation()
		}
	}
}

extension LocationSearchViewController: LocationSearchViewModelDelegate {
	func predictionsDidUpdate() {
		locationSearchView?.predictionsTableView.reloadData()
	}
}

extension LocationSearchViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellOption = tableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier)
		guard let cell = cellOption as? LocationCell else {
			fatalError("Unexpected cell")
		}
		let prediction = viewModel.predictions[indexPath.item]
		cell.prediction = prediction
		return cell
	}
		
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.predictions.count
	}
}

extension LocationSearchViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let prediction = viewModel.predictions[indexPath.item]
		showActivityIndicator(for: nil)
		viewModel.onSelectLocation(placeId: prediction.place_id, completion: {[weak self] in
			self?.removeActivityIndicator()
		})
	}
}

extension LocationSearchViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let coordinates: CLLocation = locations[0]
    manager.stopUpdatingLocation()
		viewModel.updateDeviceGeocode(from: coordinates.coordinate, onSuccess: {[weak self] in
			guard let self = self, let locationView = self.locationSearchView else { return }
			let button = locationView.showDeviceLocationIcon()
			button?.rx.tap
				.subscribe(onNext: {[unowned self] _ in self.viewModel.onSelectDeviceLocation() })
				.disposed(by: self.disposeBag)
		})
  }
}
