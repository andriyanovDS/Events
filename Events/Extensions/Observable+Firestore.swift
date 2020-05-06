//
//  Observable+Firestore.swift
//  Events
//
//  Created by Dmitry on 13.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseFirestore

extension Observable {
	
	static func fromSnapshotListener<T: Decodable>(ref: DocumentReference) -> Observable<T> {
		Observable<T>.create { observer in
			let listener = ref.addSnapshotListener(
				includeMetadataChanges: false,
				listener: { snapshot, error in
					if let error = error {
						observer.onError(error)
						return
					}
					guard let snapshot = snapshot else {
						return
					}
					do {
						let data = try snapshot.data(as: T.self)
						observer.onNext(data!)
					} catch let error {
						observer.onError(error)
					}
				}
			)
			return Disposables.create { listener.remove() }
		}
	}
  
  static func fromSnapshotListener<T: Decodable>(query: Query) -> Observable<[T]> {
    Observable<[T]>.create { observer in
      let listener = query.addSnapshotListener(
        includeMetadataChanges: false,
        listener: { snapshot, error in
          if let error = error {
            observer.onError(error)
            return
          }
          guard let snapshot = snapshot else { return }
          do {
            let data = try snapshot.documents.compactMap {
              try $0.data(as: T.self)
            }
            observer.onNext(data)
          } catch let error {
            observer.onError(error)
          }
      }
      )
      return Disposables.create { listener.remove() }
    }
  }
}
