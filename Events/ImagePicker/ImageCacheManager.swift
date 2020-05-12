//
//  ImageCacheManager.swift
//  Events
//
//  Created by Дмитрий Андриянов on 15/02/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit
import Photos
import Promises

class ImageCacheManager {
  typealias AssetProvider = (Int) -> PHAsset
  
  private var targetSize: CGSize
  private let imageManager = PHCachingImageManager()
  private var previousPreheatRect = CGRect.zero
  private let imageRequestOptions: PHImageRequestOptions?

  init(
    targetSize: CGSize,
    imageRequestOptions: PHImageRequestOptions?
  ) {
    self.targetSize = targetSize
    self.imageRequestOptions = imageRequestOptions
  }

  func setTargetSize(_ size: CGSize) {
    targetSize = size
  }

  func getImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
    imageManager.requestImage(
      for: asset,
      targetSize: targetSize,
      contentMode: .aspectFit,
      options: imageRequestOptions,
      resultHandler: { image, _ in
        completion(image)
      }
    )
  }

  func attemptToCacheAssets(_ collectionView: UICollectionView, assetProvider: AssetProvider) {
    let visibleRect = CGRect(
      origin: CGPoint(x: collectionView.contentOffset.x, y: 0),
      size: collectionView.bounds.size
    )
    let preheatRect = visibleRect.insetBy(dx: -1.5 * visibleRect.width, dy: 0)

    let delta = abs(preheatRect.midX - previousPreheatRect.midX)
    guard delta > collectionView.bounds.width / 3 else { return }

    let (added, removed) = differencesBetweenRects(previousPreheatRect, preheatRect)
    let addedAssets = added
      .flatMap { indices(in: $0, inside: collectionView) }
      .uniq()
      .map { assetProvider($0) }
    let removedAssets = removed
      .flatMap { indices(in: $0, inside: collectionView) }
      .uniq()
      .map { assetProvider($0) }

    imageManager.startCachingImages(
      for: addedAssets,
      targetSize: targetSize,
      contentMode: .aspectFit,
      options: imageRequestOptions
      )
    imageManager.stopCachingImages(
     for: removedAssets,
     targetSize: targetSize,
     contentMode: .aspectFit,
     options: imageRequestOptions
     )

    previousPreheatRect = preheatRect
  }

  private func indices(in rect: CGRect, inside collectionView: UICollectionView) -> [Int] {
    guard let layout = collectionView.collectionViewLayout as? ImagePickerCollectionViewLayout else {
      return []
    }
    let cellCount = collectionView.numberOfItems(inSection: 0)
    guard cellCount > 0 else { return [] }
    let cellTotalWidth = layout.cellSize.width + layout.minimumLineSpacing
    let lastCellIndex = collectionView.numberOfItems(inSection: 0) - 1
    let cellsInOffset = min(lastCellIndex, Int(ceil(rect.minX / cellTotalWidth)))
    let startIndex = max(0, cellsInOffset)

    let endIndex = min(
      cellCount - 1,
      max(0, Int(ceil(rect.maxX / cellTotalWidth)))
    )
    return [Int](startIndex...endIndex)
  }

  private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
    if old.intersects(new) {
      var added = [CGRect]()
      if new.maxX > old.maxX {
        added += [CGRect(x: old.maxX, y: new.origin.y,
                         width: new.maxX - old.maxX, height: new.height)]
      }
      if old.minX > new.minX {
        added += [CGRect(x: new.minX, y: new.origin.y,
                              width: old.minX - new.minX, height: new.height)]
      }
      var removed = [CGRect]()
      if new.maxX < old.maxX {
        removed += [CGRect(x: new.maxX, y: new.origin.y,
                           width: old.maxX - new.maxX, height: new.height)]
      }
      if old.minX < new.minX {
        removed += [CGRect(x: old.minX, y: new.origin.y,
                           width: new.minX - old.minX, height: new.height)]
      }
      return (added, removed)
    } else {
      return ([new], [old])
    }
  }
}
