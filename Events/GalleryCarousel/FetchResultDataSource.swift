//
//  FetchResultDataSource.swift
//  Events
//
//  Created by Dmitry on 15.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Photos.PHFetchResult
import Photos.PHAsset

class FetchResultDataSource<Cell: FetchResultDataSourceCell>: NSObject, UICollectionViewDataSource {
  typealias CellConfigurator = (Int, Cell) -> Void
  typealias CellImageSetter = (UIImage, Int, Cell) -> Void
  
  var assets: PHFetchResult<PHAsset>
  let imageCacheManager: ImageCacheManager
  var selectedAssetIndices: [Int]
  var cellConfigurator: CellConfigurator?
  var cellImageSetter: CellImageSetter?
  var selectedAssets: [PHAsset] {
    selectedAssetIndices.map { assets.object(at: $0) }
  }
  var imageRequestOptions: PHImageRequestOptions?
  
  init(
    assets: PHFetchResult<PHAsset> = PHFetchResult(),
    selectedAssetIndices: [Int] = [],
    imageRequestOptions: PHImageRequestOptions? = nil
  ) {
    self.assets = assets
    self.selectedAssetIndices = selectedAssetIndices
    self.imageRequestOptions = imageRequestOptions
    self.imageCacheManager = ImageCacheManager(
      targetSize: CGSize.zero,
      imageRequestOptions: imageRequestOptions
    )
  }
  
  func selectionIndex(forAssetAt index: Int) -> Int? {
    selectedAssetIndices.firstIndex(of: index)
  }
  
  func changeTargetSize(_ size: CGSize) {
    let scale = UIScreen.main.scale
    let transform = CGAffineTransform(scaleX: scale, y: scale)
    imageCacheManager.setTargetSize(size.applying(transform))
  }
  
  func attemptToCacheAssets(_ collectionView: UICollectionView) {
    imageCacheManager.attemptToCacheAssets(collectionView, assetProvider: {[unowned self] in
      self.assets.object(at: $0)
    })
  }
  
  func selectAsset(at index: Int) {
    if let selectedIndex = selectedAssetIndices.firstIndex(of: index) {
      selectedAssetIndices.remove(at: selectedIndex)
      return
    }
    selectedAssetIndices.append(index)
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return assets.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cellOptional = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath)
    guard let cell = cellOptional as? Cell else {
      fatalError("Unexpected cell")
    }
    let asset = assets.object(at: indexPath.item)
    cell.assetIdentifier = asset.localIdentifier
    if let cellConfigurator = self.cellConfigurator {
      cellConfigurator(indexPath.item, cell)
    }
    imageCacheManager.getImage(for: asset, completion: {[weak cell, weak self, asset] image in
      guard
        let setter = self?.cellImageSetter,
        let image = image,
        let cell = cell,
        cell.assetIdentifier == asset.localIdentifier
      else { return }
      setter(image, indexPath.item, cell)
    })
    return cell
  }
}

protocol FetchResultDataSourceCell: UICollectionViewCell, ReuseIdentifiable {
  var assetIdentifier: String? { get set }
}
