//
//  DataSource.swift
//  Events
//
//  Created by Dmitry on 05.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

protocol ReuseIdentifiable {
  static var reuseIdentifier: String { get }
}

class DataSource<Model, Cell: ReuseIdentifiable>: NSObject {
  typealias CellConfigurator = (Model, Cell, IndexPath) -> Void
  
  private(set) var models: [Model] = []
  let cellConfigurator: CellConfigurator
  
  init(models: [Model] = [], cellConfigurator: @escaping CellConfigurator) {
    self.models = models
    self.cellConfigurator = cellConfigurator
  }
  
  func set(_ models: [Model]) {
    self.models = models
  }
  
  func append(_ models: [Model]) {
    self.models.append(contentsOf: models)
  }
  
  func update(_ model: Model, at index: Int) {
    self.models[index] = model
  }
  
  func update<T>(keyPath: WritableKeyPath<Model, T>, value: T, at index: Int) {
    models[index][keyPath: keyPath] = value
  }
  
  @discardableResult
  func remove(at index: Int) -> Model {
    models.remove(at: index)
  }
  
  func model(at index: Int) -> Model {
    models[index]
  }
}

class TableViewSingleSectionDataSource<Model, Cell: ReuseIdentifiable>:
  DataSource<Model, Cell>,
  UITableViewDataSource where Cell: UITableViewCell {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return models.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellOptional = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath)
    guard let cell = cellOptional as? Cell else {
      fatalError("Unexpected cell")
    }
    let model = self.model(at: indexPath.item)
    cellConfigurator(model, cell, indexPath)
    return cell
  }
}

class CollectionViewSingleSectionDataSource<Model, Cell: ReuseIdentifiable>:
  DataSource<Model, Cell>,
  UICollectionViewDataSource where Cell: UICollectionViewCell {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cellOptional = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath)
    guard let cell = cellOptional as? Cell else {
      fatalError("Unexpected cell")
    }
    let model = self.model(at: indexPath.item)
    cellConfigurator(model, cell, indexPath)
    return cell
  }
}
