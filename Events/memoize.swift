//
//  memoize.swift
//  Events
//
//  Created by Дмитрий Андриянов on 21/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

func memoize<U: Hashable, R>(
  callback: @escaping (U) -> R
) -> (U) -> R {
  var map = [U: R]()

  return { v in
    let cached = map[v]
    return cached
      .getOrElseL {
        let value = callback(v)
        map[v] = value
        return value
      }
  }
}

func memoizeWith<U, R>(
  callback: @escaping (U) -> R,
  key: @escaping (U) -> String
) -> (U) -> R {
  var map = [String: R]()

  return { v in
    let cacheKey = key(v)
    let cached = map[cacheKey]
    return cached
      .getOrElseL {
        let value = callback(v)
        map[cacheKey] = value
        return value
      }
  }
}
