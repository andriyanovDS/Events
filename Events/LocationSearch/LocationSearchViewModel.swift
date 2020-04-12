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
								observer.on(.next(result))
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
				
	func updateDeviceGeocode(
		from coordinate: CLLocationCoordinate2D,
		onSuccess: @escaping () -> Void
	) {
		GeolocationAPI.shared.reverseGeocode(byCoordinate: coordinate)
			.then {[weak self] geocode in
				guard let self = self else { return }
				self.deviceGeocode = geocode
				onSuccess()
			}
			.catch { print($0.localizedDescription) }
	}
  
  func onSelectDeviceLocation() {
		guard let geocode = deviceGeocode else { return }
    onResult(geocode)
    cancelScreen()
  }
  
	func onSelectLocation(placeId: String, completion: @escaping () -> Void) {
		GeolocationAPI.shared.reverseGeocode(byPlaceId: placeId)
			.then {[weak self] geocode in
				guard let self = self else { return }
				self.onResult(geocode)
				self.cancelScreen()
			}
			.always { completion() }
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
