//
//  OptionalExtension.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

extension Optional {
  
  func fold<Result>(none: Result, some: (Wrapped) -> Result) -> Result {
    guard let nonOptional = self else {
      return none
    }
    return some(nonOptional)
  }
  
  func foldL<Result>(none: () -> Result, some: (Wrapped) -> Result) -> Result {
    guard let nonOptional = self else {
      return none()
    }
    return some(nonOptional)
  }
  
  func getOrElse(result: Wrapped) -> Wrapped {
    guard let nonOptional = self else {
      return result
    }
    return nonOptional
  }
  
  func getOrElseL(_ none: () -> Wrapped) -> Wrapped {
    guard let nonOptional = self else {
      return none()
    }
    return nonOptional
  }
  
  func map<T>(_ callback: (Wrapped) -> T) -> T? {
    guard let nonOptional = self else {
      return nil
    }
    return callback(nonOptional)
  }
  
  func chain<T>(_ callback: (Wrapped) -> T?) -> T? {
    guard let nonOptional = self else {
      return nil
    }
    return callback(nonOptional)
  }

  func alt(_ callback: () -> Wrapped?) -> Wrapped? {
    guard let nonOptional = self else {
      return callback()
    }
    return nonOptional
  }
}
