//
//  ImagesPreviewViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import RxFlow
import RxCocoa
import Photos

class ImagesPreviewViewModel: Stepper {
  let steps = PublishRelay<Step>()
  weak var delegate: ImagesPreviewViewModelDelegate?
  private let assets: PHFetchResult<PHAsset>
  private let imageManager: ImageCacheManager
  private let imageRequestOptions = PHImageRequestOptions()
  var assetsCount: Int {
    assets.count
  }

  init(assets: PHFetchResult<PHAsset>) {
    self.assets = assets
    let scale = UIScreen.main.scale
    let screenRect = UIScreen.main.bounds
    imageManager = ImageCacheManager(
      targetSize: CGSize(
        width: screenRect.width * scale,
        height: screenRect.height * scale
      ),
      imageRequestOptions: imageRequestOptions
    )
    imageRequestOptions.version = .current
    imageRequestOptions.resizeMode = .exact
    imageRequestOptions.isNetworkAccessAllowed = true
    imageRequestOptions.deliveryMode = .opportunistic
    imageRequestOptions.isSynchronous = false
    imageRequestOptions.progressHandler = {[weak self] progress, error, stop, info in
      DispatchQueue.main.async {
        if progress != 1.0 {
          self?.delegate?.showImageLoadingProgress()
          return
        }
        if progress == 1.0 || error != nil {
          self?.delegate?.hideImageLoadingProgress()
        }
      }
    }
  }

  func asset(at index: Int) -> PHAsset {
    return assets.object(at: index)
  }

  func image(for asset: PHAsset, onResult: @escaping (UIImage) -> Void) {
    imageManager.getImage(for: asset, onResult: onResult)
  }

  func attemptToCacheAssets(_ collectionView: UICollectionView) {
    imageManager.attemptToCacheAssets(collectionView, assetGetter: {
      self.assets.object(at: $0)
    })
  }

  func onCloseModal() {
    steps.accept(EventStep.imagesPreviewDidComplete)
  }
}

protocol ImagesPreviewViewModelDelegate: class {
  func showImageLoadingProgress()
  func hideImageLoadingProgress()
}
