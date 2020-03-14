//
//  DescriptionViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import RxFlow
import RxCocoa
import Photos

class DescriptionViewModel: Stepper {
  weak var delegate: DescriptionViewModelDelegate?
  let steps = PublishRelay<Step>()
  var descriptions: [MutableDescription] = [
    MutableDescription(isMain: true, title: nil, assets: [], text: "Test text")
  ]
  private let imageCacheManager: ImageCacheManager

  init() {
    let scale = UIScreen.main.scale
    imageCacheManager = ImageCacheManager(
      targetSize: CGSize(
        width: SELECTED_IMAGE_SIZE.width * scale,
        height: SELECTED_IMAGE_SIZE.height * scale
      ),
      imageRequestOptions: nil
    )
  }

  func openNextScreen() {
    delegate?.onResult(descriptions.map { $0.immutable() })
    steps.accept(CreateEventStep.descriptionDidComplete)
  }

  func addDescription() {
     descriptions.append(MutableDescription(isMain: false))
   }

  func remove(descriptionAtIndex: Int) {
    descriptions.remove(at: descriptionAtIndex)
  }

  func remove(asset: PHAsset, forDescriptionAtIndex index: Int) {
   var selectedAssets = descriptions[index].assets
   guard let assetIndex = selectedAssets.firstIndex(of: asset) else { return }
     selectedAssets.remove(at: assetIndex)
     descriptions[index].assets = selectedAssets
     delegate?.performCellsUpdate(
       removedIndexPaths: [IndexPath(item: assetIndex, section: 0)],
       insertedIndexPaths: []
     )
   }

   private func update(assets: [PHAsset], forDescriptionAtIndex index: Int) {
     let newAssetsSet = Set(assets.map { $0.localIdentifier })
     var selectedAssets = descriptions[index].assets
     let currentAssetsSet = Set(selectedAssets.map { $0.localIdentifier })
     let removedIndices = selectedAssets
       .enumerated()
       .filter {_, asset in !newAssetsSet.contains(asset.localIdentifier) }
       .map { index, _ in index }
     let newAssets: [PHAsset] = assets.filter { !currentAssetsSet.contains($0.localIdentifier) }
     removedIndices
       .enumerated()
       .map { $1 - $0 }
       .forEach { selectedAssets.remove(at: $0) }
     selectedAssets.insert(contentsOf: newAssets, at: selectedAssets.count)
     descriptions[index].assets = assets
     delegate?.performCellsUpdate(
       removedIndexPaths: removedIndices.map { IndexPath(item: $0, section: 0) },
       insertedIndexPaths: newAssets
         .enumerated()
         .map { index, _ in
           IndexPath(item: selectedAssets.count - newAssets.count + index, section: 0)
         }
       )
   }
}

extension DescriptionViewModel {
  func openHintPopup(popup: HintPopup) {
    steps.accept(EventStep.hintPopup(popup: popup))
  }

  func openImagePicker(activeDescription index: Int) {
    let selectedAssets = descriptions[index].assets
    steps.accept(EventStep.imagePicker(selectedAssets: selectedAssets, onComplete: { assets in
      self.update(assets: assets, forDescriptionAtIndex: index)
    }))
  }
}

extension DescriptionViewModel {
  func asset(at index: Int, forDescriptionAtIndex descriptionIndex: Int) -> PHAsset {
    return descriptions[descriptionIndex].assets[index]
  }

  func image(for asset: PHAsset, onResult: @escaping (UIImage) -> Void) {
    return imageCacheManager.getImage(for: asset, onResult: onResult)
  }

  func attemptToCacheAssets(_ collectionView: UICollectionView, forDescriptionAtIndex index: Int) {
    imageCacheManager.attemptToCacheAssets(collectionView, assetGetter: { index in
      descriptions[index].assets[index]
    })
  }
}

protocol DescriptionViewModelDelegate: class {
  var onResult: (([Description]) -> Void)! { get }
  func performCellsUpdate(removedIndexPaths: [IndexPath], insertedIndexPaths: [IndexPath])
}

struct FailedToLoadBackgroundImage: Error {}
