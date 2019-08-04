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

class LocationSearchViewController: UIViewControllerWithActivityIndicator,
    SearchBarDelegate,
    LocationSearchViewModelDelegate,
    LocationSearchStackViewDelegate {

    var viewModel: LocationSearchViewModel!
    var onClose: ((Geocode) -> Void)?
    weak var coordinator: LocationSearchCoordinator?
    var searchBar = SearchBarViewController(nibName: nil, bundle: nil)

    private let scrollView = UIScrollView()
    private let locationStackView = LocationSearchStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = LocationSearchViewModel(textField: searchBar.textField)
        viewModel.delegate = self
        viewModel.coordinator = coordinator
        searchBar.delegate = self
        locationStackView.delegate = self
        viewModel.initializeUserLocation()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onFocusTextField()
    }

    func searchBarDidCancel() {
        viewModel.cancelScreen()
    }

    @objc func onSelectLocationItem(_ button: LocationItem) {
        if let geocode = button.geocode {
            viewModel.onSelectLocation(geocode: geocode)
        } else if let placeId = button.placeId {
            viewModel.onSelectLocation(placeId: placeId)
        }
    }

    func showPredictions(_ predictions: [Prediction]) {
        locationStackView.predictions = predictions
    }

    func showCurrentLocation(geocode: Geocode) {
        locationStackView.currentLocation = geocode
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinates: CLLocation = locations[0]
        manager.stopUpdatingLocation()
        viewModel?.onReceiveCoordinates(coordinates.coordinate)
    }

    func onResult(geocode: Geocode) {
        onClose?(geocode)
    }

    private func onFocusTextField() {
        searchBar.textField.becomeFirstResponder()
    }
}

extension LocationSearchViewController {

    func setupView() {
        guard let searchBar = searchBar.view else {
            return
        }
        view.backgroundColor = .white
        view.addSubview(searchBar)
        setupSearchBarViewConstraints()
        setupScrollView()
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

    func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        setupScrollViewConstraints()
        setupStackView()
    }

    func setupStackView() {
        locationStackView.axis = .vertical
        locationStackView.alignment = .fill
        locationStackView.distribution = .fillEqually
        locationStackView.spacing = 10
        scrollView.addSubview(locationStackView)

        setupStackViewConstraints()
    }

    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.topAnchor.constraint(equalTo: searchBar.view.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }

    func setupStackViewConstraints() {
        locationStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            locationStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            locationStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            locationStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            locationStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
    }
}
