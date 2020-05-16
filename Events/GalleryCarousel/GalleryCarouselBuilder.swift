//
//  GalleryCarouselConfigurator.swift
//  Events
//
//  Created by Dmitry on 15.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import Photos

class GalleryCarouselBuilder {
  
  private func configureRequestOptions(_ options: PHImageRequestOptions) {
    options.version = .current
    options.resizeMode = .exact
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .opportunistic
    options.isSynchronous = false
  }
  
  func make(
    assets: PHFetchResult<PHAsset>,
    selectedAssetIndices: [Int],
    sharedImage: SharedImage,
    onAssetDidSelected: @escaping (Int) -> Void
  ) -> GalleryCarouselViewController {
    let requestOptions = PHImageRequestOptions()
    configureRequestOptions(requestOptions)
    let dataSource = FetchResultDataSource<GalleryCarouselCell>(
      assets: assets,
      selectedAssetIndices: selectedAssetIndices,
      imageRequestOptions: requestOptions
    )
    let viewModel = GalleryCarouselViewModel()
    let viewController = GalleryCarouselViewController(
      viewModel: viewModel,
      sharedImage: sharedImage,
      dataSource: dataSource,
      onAssetDidSelected: onAssetDidSelected
    )
    return viewController
  }
}
