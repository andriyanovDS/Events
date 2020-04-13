//
//  Observable+fromPromise.swift
//  Events
//
//  Created by Dmitry on 12.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import Promises

extension Observable {
	
	static func fromPromise<T>(_ promise: Promise<T>) -> Observable<T> {
		Observable<T>.create { observer in
			promise
				.then { result in
					observer.onNext(result)
					observer.onCompleted()
				}
				.catch { observer.onError($0) }
			return Disposables.create { }
		}
	}
	
	static func fromPromise<T>(
		_ promise: Promise<T>,
		defaultValueGetter: @escaping () -> T
	) -> Observable<T> {
		Observable<T>.create { observer in
			promise
				.then { result in
					observer.onNext(result)
					observer.onCompleted()
				}
				.catch { error in
					print(error.localizedDescription)
					observer.onNext(defaultValueGetter())
					observer.onCompleted()
				}
			return Disposables.create { }
		}
	}
	
	func toPromise(disposeBag: DisposeBag) -> Promise<Element> {
		Promise { resolve, reject in
			self
				.take(1)
				.subscribe(onNext: resolve, onError: reject)
				.disposed(by: disposeBag)
		}
	}
}
