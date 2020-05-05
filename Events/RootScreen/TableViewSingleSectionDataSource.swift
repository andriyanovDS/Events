//
//  RootScreenDataSource.swift
//  Events
//
//  Created by Dmitry on 05.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class TableViewSingleSectionDataSource<Model, Cell: UITableViewCellIdentifiable>: NSObject, UITableViewDataSource {
  typealias CellConfigurator = (Model, Cell) -> Void
  
  private(set) var models: [Model] = []
  private let cellConfigurator: CellConfigurator
  
  init(models: [Model] = [], cellConfigurator: @escaping CellConfigurator) {
    self.cellConfigurator = cellConfigurator
  }
  
  func appendModels(_ models: [Model]) {
    self.models.append(contentsOf: models)
  }
  
  func model(at index: Int) -> Model {
    models[index]
  }
  
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
    cellConfigurator(model, cell)
    return cell
  }
}

protocol UITableViewCellIdentifiable: UITableViewCell {
  static var reuseIdentifier: String { get }
}
