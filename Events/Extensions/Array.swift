//
//  Array.swift
//  Events
//
//  Created by Дмитрий Андриянов on 11/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

extension Array {
  func chunks(_ chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: self.count, by: chunkSize).map {
      Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
    }
  }
}

extension Array where Element: Equatable {
	func uniq() -> [Element] {
		self.reduce([], { result, element in
			if !result.contains(where: { $0 == element }) {
				return result + [element]
			}
			return result
		})
	}
}
