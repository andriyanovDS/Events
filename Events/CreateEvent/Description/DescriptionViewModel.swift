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

class DescriptionViewModel: Stepper, ResultProvider {
  weak var delegate: DescriptionViewModelDelegate?
  let steps = PublishRelay<Step>()
  let onResult: ResultHandler<[DescriptionWithAssets]>
  private let imageCacheManager: ImageCacheManager
	private lazy var imageLoadingOptions: PHContentEditingInputRequestOptions = {
		let options = PHContentEditingInputRequestOptions()
		options.isNetworkAccessAllowed = true
		return options
	}()
	
  init(onResult: @escaping ResultHandler<[DescriptionWithAssets]>) {
    self.onResult = onResult
    let scale = UIScreen.main.scale
    let transform = CGAffineTransform(scaleX: scale, y: scale)
    imageCacheManager = ImageCacheManager(
      targetSize: SelectedImageCell.Constants.imageSize.applying(transform),
      imageRequestOptions: nil
    )
  }

  func openNextScreen(with result: [DescriptionWithAssets]) {
    onResult(result)
    steps.accept(CreateEventStep.descriptionDidComplete)
  }
	
	// https://stackoverflow.com/a/58541993
  private func createTemporaryURL(forFileAt url: URL, assetId: String) -> URL {
		let fileManager = FileManager.default
		let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(
      assetId.replacingOccurrences(of: "/", with: "-")
    )
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
	
  private func loadUrl(for asset: PHAsset) -> Promise<DescriptionWithAssets.Asset> {
    Promise<DescriptionWithAssets.Asset>(on: .global()) { resolve, reject in
			asset.requestContentEditingInput(
				with: self.imageLoadingOptions,
				completionHandler: { (input, _) in
					
				guard let input = input else {
					reject(UploadAssetError())
					return
				}
				resolve(DescriptionWithAssets.Asset(
					asset: asset,
          localUrl: self.createTemporaryURL(
            forFileAt: input.fullSizeImageURL!,
            assetId: asset.localIdentifier
          )
				))
			})
		}
	}
}

extension DescriptionViewModel {
  func openHintPopup(popup: HintPopup) {
    steps.accept(EventStep.hintPopup(popup: popup))
  }

  func openImagePicker(
    withSelectedAssets assets: [DescriptionWithAssets.Asset],
    completion: @escaping ([DescriptionWithAssets.Asset]) -> Void
  ) {
		steps.accept(EventStep.imagePicker(
			selectedAssets: assets.map { $0.asset },
			onComplete: {[weak self] assets in
				guard let self = self else { return }
				self.delegate?.showProgress()
				let urlsPromise = all(on: .global(), assets.map { self.loadUrl(for: $0) })
				urlsPromise
					.then { completion($0) }
					.always {[weak self] in self?.delegate?.hideProgress() }
					.catch { error in
						print("Failed to load assets", error.localizedDescription)
					}
			}
		))
  }
}

extension DescriptionViewModel {
  func image(for asset: PHAsset, onResult: @escaping (UIImage?) -> Void) {
    return imageCacheManager.getImage(for: asset, completion: onResult)
  }

  func attemptToCacheAssets(_ collectionView: UICollectionView, assetGetter: ImageCacheManager.AssetProvider) {
    imageCacheManager.attemptToCacheAssets(collectionView, assetProvider: assetGetter)
  }
}

protocol DescriptionViewModelDelegate: class {
	func showProgress()
	func hideProgress()
}

struct FailedToLoadBackgroundImage: Error {}
