//
//  DescriptionDataSource.swift
//  Events
//
//  Created by Dmitry on 05.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation

class DescriptionDataSource {
  typealias AssetsDataSource = CollectionViewSingleSectionDataSource<DescriptionWithAssets.Asset, SelectedImageCell>
  typealias DescriptionDataSource = CollectionViewSingleSectionDataSource<DescriptionWithAssets, DescriptionCellView>
  typealias AssetCellConfigurator = AssetsDataSource.CellConfigurator
  typealias DescriptionCellConfigurator =
    (DescriptionWithAssets, DescriptionCellView, (isActive: Bool, isLast: Bool)) -> Void
  
  let assetsDataSource: AssetsDataSource
  var descriptionDataSource: DescriptionDataSource!
  private(set) var activeDescriptionIndex: Int = 0
  var activeDescription: DescriptionWithAssets {
    descriptionDataSource.model(at: activeDescriptionIndex)
  }
  var descriptions: [DescriptionWithAssets] {
    descriptionDataSource.models
  }
  var assets: [DescriptionWithAssets.Asset] {
    assetsDataSource.models
  }
  
  init(
    assetCellConfigurator: @escaping AssetCellConfigurator,
    descriptionCellConfigurator: @escaping DescriptionCellConfigurator
  ) {
    self.assetsDataSource = AssetsDataSource(cellConfigurator: assetCellConfigurator)
    let initialDescription = DescriptionWithAssets(isMain: true)
    self.descriptionDataSource = DescriptionDataSource(models: [initialDescription]) {
      [unowned self] (description, cell, indexPath) in
      let isActive = indexPath.item == self.activeDescriptionIndex
      let isLast = indexPath.item == self.descriptionDataSource.models.endIndex - 1
      descriptionCellConfigurator(description, cell, (isActive: isActive, isLast: isLast))
    }
  }
  
  func addDescription() {
    descriptionDataSource.append([
      DescriptionWithAssets(isMain: false)
    ])
    assetsDataSource.set([])
    activeDescriptionIndex = descriptionDataSource.models.endIndex - 1
  }
  
  func updateActiveDescriptionTitle(_ title: String) {
    descriptionDataSource.update(keyPath: \.title, value: title, at: activeDescriptionIndex)
  }
  
  func updateActiveDescriptionText(_ text: String) {
    descriptionDataSource.update(keyPath: \.text, value: text, at: activeDescriptionIndex)
  }
  
  func removeDescription(at index: Int) {
    descriptionDataSource.remove(at: index)
    if activeDescriptionIndex == index {
      activeDescriptionIndex = index - 1
    } else {
      activeDescriptionIndex = max(0, activeDescriptionIndex - 1)
    }
    let activeDescription = descriptionDataSource.model(at: activeDescriptionIndex)
    assetsDataSource.set(activeDescription.assets)
  }
  
  func selectDescription(at index: Int) {
    activeDescriptionIndex = index
    let activeDescription = descriptionDataSource.model(at: activeDescriptionIndex)
    assetsDataSource.set(activeDescription.assets)
  }
  
  func moveAsset(from index: Int, to destinationIndex: Int) {
    var assets = assetsDataSource.models
    let asset = assets.remove(at: index)
    assets.insert(asset, at: destinationIndex)
    assetsDataSource.set(assets)
    commitActiveDescriptionAssets()
  }
  
  func removeAsset(at index: Int) {
    assetsDataSource.remove(at: index)
    commitActiveDescriptionAssets()
  }
  
  func updateAssets(_ assets: [DescriptionWithAssets.Asset]) -> (removed: [IndexPath], inserted: [IndexPath]) {
    let newAssetsSet = Set(assets.map { $0.asset.localIdentifier })
    var selectedAssets = assetsDataSource.models
    let currentAssetsSet = Set(selectedAssets.map { $0.asset.localIdentifier })
    let removedIndices = selectedAssets
      .enumerated()
      .filter { _, v in !newAssetsSet.contains(v.asset.localIdentifier) }
      .map { index, _ in index }
    let newAssets: [DescriptionWithAssets.Asset] = assets.filter {
      !currentAssetsSet.contains($0.asset.localIdentifier)
    }
    removedIndices
      .enumerated()
      .map { $1 - $0 }
      .forEach { selectedAssets.remove(at: $0) }
    selectedAssets.insert(contentsOf: newAssets, at: selectedAssets.count)
    assetsDataSource.set(selectedAssets)
    commitActiveDescriptionAssets()
    return (
      removedIndices.map { IndexPath(item: $0, section: 0) },
      newAssets
        .enumerated()
        .map { IndexPath(item: selectedAssets.count - newAssets.count + $0.offset, section: 0) }
    )
  }
  
  private func commitActiveDescriptionAssets() {
    var description = descriptionDataSource.model(at: activeDescriptionIndex)
    description.assets = assetsDataSource.models
    descriptionDataSource.update(description, at: activeDescriptionIndex)
  }
}
