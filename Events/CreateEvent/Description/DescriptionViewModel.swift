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
import Promises

class DescriptionViewModel: Stepper {
  weak var delegate: DescriptionViewModelDelegate?
  let steps = PublishRelay<Step>()
  var descriptions: [MutableDescription] = [
    MutableDescription(isMain: true, title: nil, assets: [], text: "Test text")
  ]
  private let imageCacheManager: ImageCacheManager
	private lazy var imageLoadingOptions: PHContentEditingInputRequestOptions = {
		let options = PHContentEditingInputRequestOptions()
		options.isNetworkAccessAllowed = true
		return options
	}()
	
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
		guard let assetIndex = selectedAssets.firstIndex(where: { $0.asset == asset }) else { return }
		selectedAssets.remove(at: assetIndex)
		descriptions[index].assets = selectedAssets
		delegate?.performCellsUpdate(
			removedIndexPaths: [IndexPath(item: assetIndex, section: 0)],
			insertedIndexPaths: []
		)
   }

	private func update(assets: [DescriptionAsset], forDescriptionAtIndex index: Int) {
		let newAssetsSet = Set(assets.map { $0.asset.localIdentifier })
		var selectedAssets = descriptions[index].assets
		let currentAssetsSet = Set(selectedAssets.map { $0.asset.localIdentifier })
		let removedIndices = selectedAssets
			.enumerated()
			.filter {_, v in !newAssetsSet.contains(v.asset.localIdentifier) }
			.map { index, _ in index }
		let newAssets: [DescriptionAsset] = assets.filter { !currentAssetsSet.contains($0.asset.localIdentifier) }
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
	
	// https://stackoverflow.com/a/58541993
	private func createTemporaryURLforFile(url: URL) -> URL {
		let fileManager = FileManager.default
		let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
		let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(url.lastPathComponent)
		if fileManager.fileExists(atPath: temporaryFileURL.path) {
			return temporaryFileURL
		}
		do {
			try fileManager.copyItem(at: url.absoluteURL, to: temporaryFileURL)
		} catch {
			print("There was an error copying the file to the temporary location.")
		}
		return temporaryFileURL
	}
	
	private func loadUrl(for asset: PHAsset) -> Promise<DescriptionAsset> {
		Promise<DescriptionAsset>(on: .global()) { resolve, reject in
			asset.requestContentEditingInput(
				with: self.imageLoadingOptions,
				completionHandler: { (input, _) in
					
				guard let input = input else {
					reject(UploadAssetError())
					return
				}
				resolve(DescriptionAsset(
					asset: asset,
					localUrl: self.createTemporaryURLforFile(url: input.fullSizeImageURL!)
				))
			})
		}
	}
}

extension DescriptionViewModel {
  func openHintPopup(popup: HintPopup) {
    steps.accept(EventStep.hintPopup(popup: popup))
  }

  func openImagePicker(activeDescription index: Int) {
    let selectedAssets = descriptions[index].assets
		steps.accept(EventStep.imagePicker(
			selectedAssets: selectedAssets.map { $0.asset },
			onComplete: {[weak self] assets in
				guard let self = self else { return }
				self.delegate?.showProgress()
				let urlsPromise = all(on: .global(), assets.map { self.loadUrl(for: $0) })
				urlsPromise
					.then { self.update(assets: $0, forDescriptionAtIndex: index) }
					.always {
						self.delegate?.hideProgress()
					}
					.catch { error in
						print("Failed to load assets", error.localizedDescription)
					}
			}
		))
  }
}

extension DescriptionViewModel {
  func asset(at index: Int, forDescriptionAtIndex descriptionIndex: Int) -> PHAsset {
		return descriptions[descriptionIndex].assets[index].asset
  }

  func image(for asset: PHAsset, onResult: @escaping (UIImage) -> Void) {
    return imageCacheManager.getImage(for: asset, onResult: onResult)
  }

  func attemptToCacheAssets(_ collectionView: UICollectionView, forDescriptionAtIndex index: Int) {
    imageCacheManager.attemptToCacheAssets(collectionView, assetGetter: { index in
			descriptions[index].assets[index].asset
    })
  }
}

protocol DescriptionViewModelDelegate: class {
  var onResult: (([DescriptionWithAssets]) -> Void)! { get }
	func showProgress()
	func hideProgress()
  func performCellsUpdate(removedIndexPaths: [IndexPath], insertedIndexPaths: [IndexPath])
}

struct FailedToLoadBackgroundImage: Error {}
