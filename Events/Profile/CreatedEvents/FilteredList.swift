//
//  FilteredList.swift
//  Events
//
//  Created by Dmitry on 06.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation

@propertyWrapper
struct FilteredList<T: Equatable> {
  var query: String {
    didSet { updateFilteredList() }
  }
  private var lastRemovedElement: (element: T, index: Int)?
  private let keyPath: KeyPath<T, String>
  private var list: [T] = []
  private var filteredList: [T] = []
  var wrappedValue: [T] {
    get { filteredList }
    set {
      list = newValue
      updateFilteredList()
    }
  }
  
  init(query: String = "", list: [T] = [], keyPath: KeyPath<T, String>) {
    self.keyPath = keyPath
    self.query = query
    self.wrappedValue = list
  }
  
  mutating private func updateFilteredList() {
    filteredList = query.isEmpty
      ? list
      : list.filter { $0[keyPath: keyPath].contains(query) }
  }
}

extension FilteredList where T: Equatable {
  mutating func revertLastRemove() -> T? {
    guard let (element, index) = lastRemovedElement else { return nil }
    list.insert(element, at: index)
    updateFilteredList()
    return element
  }
  
  mutating func remove(element: T) {
    guard let index = list.firstIndex(where: { $0 == element }) else {
      assertionFailure("Attempt to remove element not from list")
      return
    }
    let element = list.remove(at: index)
    lastRemovedElement = (element, index)
    updateFilteredList()
  }
}
