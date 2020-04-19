//
//  FirestoreQuery+Promise.swift
//  Events
//
//  Created by Dmitry on 19.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import Promises
import FirebaseFirestore

extension Query {
  func getDocuments<T: Decodable>() -> Promise<[T]> {
    Promise { resolve, reject in
      self.getDocuments(completion: { snapshot, error in
        if let error = error {
          reject(error)
          return
        }
        guard let documents = snapshot?.documents else {
          resolve([])
          return
        }
        do {
          let list = try documents.compactMap {
            try $0.data(as: T.self)
          }
          resolve(list)
        } catch let error {
          reject(error)
        }
      })
    }
  }
}
