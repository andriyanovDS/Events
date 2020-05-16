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

class ImagePickerDataSource: FetchResultDataSource<ImagePreviewCell>, ImagePickerViewDataSource {
  private(set) var initialSelectedAssetsIndices: [Int] = []
  var initialSelectedAssets: [PHAsset] {
    initialSelectedAssetsIndices.map { assets.object(at: $0) }
  }
  
  func updateAssets(_ assets: PHFetchResult<PHAsset>, whereSelected indices: [Int]) {
    self.assets = assets
    self.selectedAssetIndices = indices
    self.initialSelectedAssetsIndices = indices
  }
}

extension ImagePickerDataSource {
  func loadSharedImage(forAssetAt index: Int, completion: @escaping (SharedImage?) -> Void) {
    let asset = assets.object(at: index)
    let options = PHImageRequestOptions()
    options.isSynchronous = false
    options.deliveryMode = .highQualityFormat
    let scale = UIScreen.main.scale
    let transform = CGAffineTransform(scaleX: scale, y: scale)
    PHImageManager.default().requestImage(
      for: asset,
      targetSize: UIScreen.main.bounds.size.applying(transform),
      contentMode: .aspectFit,
      options: options,
      resultHandler: {[weak self] image, _ in
        if let image = image {
          completion(SharedImage(index: index, image: image))
          return
        }
        self?.imageCacheManager.getImage(for: asset, completion: { image in
          if let image = image {
            completion(SharedImage(index: index, image: image))
            return
          }
          completion(nil)
        })
      }
    )
  }
}
