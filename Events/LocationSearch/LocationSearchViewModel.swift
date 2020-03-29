//
//  LocationSearchViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 14/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift
import RxFlow
import RxCocoa
import CoreLocation

class LocationSearchViewModel: Stepper, ScreenWithResult {
  let steps = PublishRelay<Step>()
	var onResult: ((Geocode) -> Void)!
	weak var delegate: LocationSearchViewModelDelegate?
	var predictions: [Prediction] = []
	private let disposeBag = DisposeBag()
	private var deviceGeocode: Geocode?

	func register(textField: UITextField) {
		let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
		textField.rx.text.orEmpty
			.throttle(.milliseconds(100), scheduler: scheduler)
			.distinctUntilChanged()
		  .observeOn(scheduler)
			.flatMapLatest { input -> Observable<[Prediction]> in
				if input.isEmpty { return .just([])}
				return Observable<[Prediction]>.create({ observer in
					let cancelRequest = GeolocationAPI.shared.predictions(
						input: input,
						completion: { result in
							switch result {
							case .success(let result):
								observer.on(.next(result.predictions))
								observer.on(.completed)
							case .failure:
								observer.on(.error(PredictionsError.apiFailure))
							}
						}
					)
					return Disposables.create { cancelRequest() }
				})
			}
			.catchError { _ in Observable<[Prediction]>.of([]) }
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] predictions in
				self?.predictions = predictions
				self?.delegate?.predictionsDidUpdate()
			})
			.disposed(by: disposeBag)
		
	}
				
	func updateDeviceGecode(
		from coordinate: CLLocationCoordinate2D,
		onSuccess: @escaping () -> Void
	) {
		let location = GetAddressByCoordinate(
			lng: coordinate.longitude,
			lat: coordinate.latitude
		)
		GeolocationAPI.shared.reverseGeocodeByCoordinate(
			coordinate: location,
			completion: {[weak self] result in
				switch result {
				case .success(let geocodes):
					guard let geocode = geocodes.mainGeocode() else {
						return
					}
					self?.deviceGeocode = geocode
					DispatchQueue.main.async {
						onSuccess()
					}
				case .failure(let error):
					print(error.localizedDescription)
				}
		})
	}
  
  func onSelectDeviceLocation() {
		guard let geocode = deviceGeocode else { return }
    onResult(geocode)
    cancelScreen()
  }
  
	func onSelectLocation(placeId: String, completion: @escaping () -> Void) {
    GeolocationAPI.shared.reverseGeocodeByPlaceId(
      params: GetAddressByPlaceId(placeId: placeId),
      completion: { [weak self] result in
        switch result {
        case .success(let geocodes):
          guard let geocode = geocodes.mainGeocode() else {
            return
          }
          DispatchQueue.main.async {
            self?.onResult(geocode)
            self?.cancelScreen()
						completion()
          }
        case .failure:
          print("Failure", result)
        }
      }
    )
  }
  
	func cancelScreen() {
    steps.accept(EventStep.locationSearchDidCompete)
  }
}

enum PredictionsError: Error {
  case apiFailure
}

protocol LocationSearchViewModelDelegate: class {
  func predictionsDidUpdate()
}
