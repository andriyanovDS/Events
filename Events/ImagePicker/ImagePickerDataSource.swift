//
//  ImagePickerDataSource.swift
//  Events
//
//  Created by Dmitry on 11.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Photos.PHAsset
import Foundation

class ImagePickerDataSource: NSObject, ImagePickerViewDataSource {
  typealias Cell = ImagePreviewCell
  typealias CellConfigurator = (CellConfiguration, Cell) -> Void

  private(set) var initialSelectedAssetsIndices: [Int] = []
  private(set) var selectedAssetIndices: [Int] = []
  private(set) var assets: PHFetchResult<PHAsset> = PHFetchResult()
  private let cellConfigurator: CellConfigurator
  private let imageCacheManager: ImageCacheManager
  var selectedAssets: [PHAsset] {
    selectedAssetIndices.map { assets.object(at: $0) }
  }
  var initialSelectedAssets: [PHAsset] {
    initialSelectedAssetsIndices.map { assets.object(at: $0) }
  }
  
  init(cellConfigurator: @escaping CellConfigurator) {
    self.cellConfigurator = cellConfigurator
    self.imageCacheManager = ImageCacheManager(targetSize: CGSize.zero, imageRequestOptions: nil)
  }

  func updateAssets(_ assets: PHFetchResult<PHAsset>, whereSelected indices: [Int]) {
    self.assets = assets
    self.selectedAssetIndices = indices
    self.initialSelectedAssetsIndices = indices
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
}

extension ImagePickerDataSource: UICollectionViewDataSource {
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
    let selectedPosition = selectedAssetIndices.firstIndex(of: indexPath.item)
    let configuration = CellConfiguration(
      assetIdentifier: asset.localIdentifier,
      index: indexPath.item,
      selectedPosition: selectedPosition.map { $0 + 1 }
    )
    cellConfigurator(configuration, cell)
    imageCacheManager.getImage(for: asset, completion: {[weak cell, asset] image in
      guard
        let image = image,
        let cell = cell,
        cell.assetIdentifier == asset.localIdentifier
        else { return }
      cell.setImage(image: image)
    })
    return cell
  }
}

extension ImagePickerDataSource {
  func loadSharedImage(forAssetAt index: Int, completion: @escaping (SharedImage?) -> Void) {
    let asset = assets.object(at: index)
    let options = PHImageRequestOptions()
    options.isSynchronous = false
    options.deliveryMode = .highQualityFormat
    let scale = UIScreen.main.scale
    PHImageManager.default().requestImage(
      for: asset,
      targetSize: CGSize(
        width: UIScreen.main.bounds.width * scale,
        height: UIScreen.main.bounds.height * scale
      ),
      contentMode: .aspectFit,
      options: options,
      resultHandler: {[weak self] image, _ in
        if let image = image {
          completion(SharedImage(index: index, image: image, isICloudAsset: false))
          return
        }
        guard let self = self else { return }
        self.imageCacheManager.getImage(for: asset, completion: { image in
          if let image = image {
            completion(SharedImage(index: index, image: image, isICloudAsset: true))
            return
          }
          completion(nil)
        })
      }
    )
  }
}

extension ImagePickerDataSource {
  struct CellConfiguration {
    let assetIdentifier: String
    let index: Int
    let selectedPosition: Int?
  }
}
