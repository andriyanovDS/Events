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
  let storage: Storage<DescriptionWithAssets>
  private let imageCacheManager: ImageCacheManager
	private lazy var imageLoadingOptions: PHContentEditingInputRequestOptions = {
		let options = PHContentEditingInputRequestOptions()
		options.isNetworkAccessAllowed = true
		return options
	}()
	
  init() {
    storage = Storage(values: [
      DescriptionWithAssets(isMain: true, title: nil, assets: [], text: "")
    ])!
    let scale = UIScreen.main.scale
    let transform = CGAffineTransform(scaleX: scale, y: scale)
    imageCacheManager = ImageCacheManager(
      targetSize: SelectedImageCell.Constants.imageSize.applying(transform),
      imageRequestOptions: nil
    )
  }
  
  func moveAsset(at position: Int, to: Int) {
    var assets = storage.assets
    let asset = assets.remove(at: position)
    assets.insert(asset, at: to)
    storage.assets = assets
  }
  
  func descriptionDidSelected(at index: Int) {
    storage.activeIndex = index
  }

  func openNextScreen() {
    delegate?.onResult(storage.values)
    steps.accept(CreateEventStep.descriptionDidComplete)
  }

  func addDescription() {
    storage.add(DescriptionWithAssets(isMain: false))
    storage.activeIndex = storage.count - 1
   }

  func removeDescription(at index: Int) {
    storage.remove(at: index)
    if storage.activeIndex == index {
      storage.activeIndex = index - 1
    } else {
      storage.activeIndex -= 1
    }
  }

  func removeAsset(_ asset: PHAsset) {
    var selectedAssets = storage.assets
		guard let assetIndex = selectedAssets.firstIndex(where: { $0.asset == asset }) else { return }
		selectedAssets.remove(at: assetIndex)
    storage.assets = selectedAssets
		delegate?.performCellsUpdate(
			removedIndexPaths: [IndexPath(item: assetIndex, section: 0)],
			insertedIndexPaths: []
		)
   }

  private func update(assets: [DescriptionWithAssets.Asset]) {
		let newAssetsSet = Set(assets.map { $0.asset.localIdentifier })
    var selectedAssets = storage.assets
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
    storage.assets = assets
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
  private func createTemporaryURL(forFileAt url: URL) -> URL {
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
					localUrl: self.createTemporaryURL(forFileAt: input.fullSizeImageURL!)
				))
			})
		}
	}
}

extension DescriptionViewModel {
  func openHintPopup(popup: HintPopup) {
    steps.accept(EventStep.hintPopup(popup: popup))
  }

  @objc func openImagePicker() {
    let selectedAssets = storage.assets
		steps.accept(EventStep.imagePicker(
			selectedAssets: selectedAssets.map { $0.asset },
			onComplete: {[weak self] assets in
				guard let self = self else { return }
				self.delegate?.showProgress()
				let urlsPromise = all(on: .global(), assets.map { self.loadUrl(for: $0) })
				urlsPromise
					.then {[weak self] in self?.update(assets: $0) }
					.always {[weak self] in self?.delegate?.hideProgress() }
					.catch { error in
						print("Failed to load assets", error.localizedDescription)
					}
			}
		))
  }
}

extension DescriptionViewModel {
  func image(for asset: PHAsset, onResult: @escaping (UIImage) -> Void) {
    return imageCacheManager.getImage(for: asset, onResult: onResult)
  }

  func attemptToCacheAssets(_ collectionView: UICollectionView) {
    imageCacheManager.attemptToCacheAssets(collectionView, assetGetter: { index in
			storage.assets[index].asset
    })
  }
}

extension DescriptionViewModel {
  @dynamicMemberLookup
  class Storage<T> {
    var activeIndex: Int = 0
    private var _values: [T]
    var count: Int { _values.count }
    var values: [T] { _values }
    
    init?(values: [T]) {
      if values.isEmpty { return nil }
      self._values = values
    }
    
    subscript<V>(dynamicMember keyPath: WritableKeyPath<T, V>) -> V {
      get { _values[activeIndex][keyPath: keyPath] }
      set { _values[activeIndex][keyPath: keyPath] = newValue }
    }
    
    subscript(dynamicMember member: Int) -> T { _values[member] }
    
    func add(_ value: T) {
      _values.append(value)
    }
    
    @discardableResult
    func remove(at index: Int) -> T {
      _values.remove(at: index)
    }
  }
}

protocol DescriptionViewModelDelegate: class {
  var onResult: (([DescriptionWithAssets]) -> Void)! { get }
	func showProgress()
	func hideProgress()
  func performCellsUpdate(removedIndexPaths: [IndexPath], insertedIndexPaths: [IndexPath])
}

struct FailedToLoadBackgroundImage: Error {}
