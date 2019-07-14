//
//  LocationSearchViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 14/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class LocationSearchViewModel {
    let apiService = GeolocationAPI()
    var disposable: Disposable?
    weak var delegate: LocationSearchViewModelDelegate?

    init(textField: UITextField) {
        disposable = textField.rx.text.orEmpty
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest({ [weak self] input -> Observable<[Prediction]> in
                if input.isEmpty {
                    return .just([])
                }
                return Observable<[Prediction]>.create({ observer in
                    self?.apiService.predictions(input: input, completion: { result in
                        switch result {
                        case .success(let result):
                            observer.on(.next(result.predictions))
                        case .failure:
                            observer.on(.error(PredictionsError.apiFailure))
                        }
                    })
                    return Disposables.create {

                    }
                })
            })
            .catchError({_ in Observable<[Prediction]>.of([]) })
            .subscribe(onNext: { [weak self] predictions in
                DispatchQueue.main.async {
                    self?.delegate?.showPredictions(predictions)
                }
            })

    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    func initializeUserLocation() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = delegate
            locationManager.startUpdatingLocation()

            onReceiveCoordinates(CLLocationCoordinate2D(latitude: 55.755786, longitude: 37.617633))
        }
    }

    func onReceiveCoordinates(_ coordinate: CLLocationCoordinate2D) {
        let location = GetAddressByCoordinate(
            lng: coordinate.longitude,
            lat: coordinate.latitude
        )
        apiService.reverseGeocodeByCoordinate(
            coordinate: location,
            completion: {[weak self] result in
                switch result {
                case .success(let geocodes):
                    guard let geocode = geocodes.mainGeocode() else {
                        return
                    }
                    DispatchQueue.main.async {
                        self?.delegate?.showCurrentLocation(geocode: geocode)
                    }
                case .failure:
                    print("Failure", result)
                }
        })
    }

    func onSelectLocation(geocode: Geocode) {
        onChangeUserLocation(geocode: geocode)
        cancelScreen()
    }

    func onSelectLocation(placeId: String) {
        delegate?.showActivityIndicator(for: nil)
        apiService.reverseGeocodeByPlaceId(
            params: GetAddressByPlaceId(placeId: placeId),
            completion: { [weak self] result in
                switch result {
                case .success(let geocodes):
                    guard let geocode = geocodes.mainGeocode() else {
                        return
                    }
                    DispatchQueue.main.async {
                        self?.delegate?.removeActivityIndicator()
                        onChangeUserLocation(geocode: geocode)
                        self?.cancelScreen()
                    }
                case .failure:
                    print("Failure", result)
                }
            }
        )
    }

    func cancelScreen() {
        self.delegate?.navigationController?.popViewController(animated: false)
        self.delegate?.dismiss(animated: false, completion: nil)
    }
}

enum PredictionsError: Error {
    case apiFailure
}

protocol LocationSearchViewModelDelegate: UIViewControllerWithActivityIndicator, CLLocationManagerDelegate {

    func showCurrentLocation(geocode: Geocode)
    func showPredictions(_ predictions: [Prediction])
}
