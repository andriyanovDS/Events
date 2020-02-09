//
//  ImagesPreviewVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Hero
import Stevia
import Photos

class ImagesPreviewVC: UIViewController {
  var imagesPreviewView: ImagesPreviewView?
  var activeIndex: Int
  let assets: PHFetchResult<PHAsset>
  var scrollOnIndex: Int
  var selectedImageIndices: [Int]
  let onResult: ([Int]) -> Void
  let viewModel: ImagesPreviewViewModel
  let layout = UICollectionViewFlowLayout()
  let collectionView: UICollectionView
	private var isInitialOffsetDidSet: Bool = false
	private var imageManager = PHImageManager()
	private var imageRequestOptions: PHImageRequestOptions = {
		let requestOptions = PHImageRequestOptions()
		requestOptions.version = .current
		requestOptions.deliveryMode = .highQualityFormat
    requestOptions.isSynchronous = false
		return requestOptions
	}()
	private let imageSize = CGSize(
		width: UIScreen.main.bounds.width,
		height: UIScreen.main.bounds.height
	)

  init(
    viewModel: ImagesPreviewViewModel,
    assets: PHFetchResult<PHAsset>,
    startAt index: Int,
    selectedImageIndices: [Int],
    onResult: @escaping ([Int]) -> Void
  ) {
    self.viewModel = viewModel
    self.assets = assets
    self.selectedImageIndices = selectedImageIndices
    activeIndex = index
    scrollOnIndex = index
    self.onResult = onResult
    collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    layout.itemSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height
    )
    layout.scrollDirection = .horizontal
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.collectionViewLayout = layout
    collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: "ImageViewCell")

    let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRecognizer))
    collectionView.panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture))
    collectionView.addGestureRecognizer(swipeRecognizer)

    sutupView()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if !isInitialOffsetDidSet && activeIndex > 0 {
      collectionView.scrollToItem(
        at: IndexPath(item: activeIndex, section: 0),
        at: .centeredHorizontally,
        animated: false
      )
			isInitialOffsetDidSet = true
    }
  }

  private func sutupView() {
    imagesPreviewView = ImagesPreviewView(collectionView: collectionView)
    view = imagesPreviewView
    if let selectedImageIndex = selectedImageIndices.firstIndex(of: activeIndex) {
      imagesPreviewView?.selectButton.setCount(selectedImageIndex + 1)
    }
    imagesPreviewView?.selectButton.addTarget(self, action: #selector(onSelectImage), for: .touchUpInside)
    imagesPreviewView?.backButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
  }

  @objc private func closeModal() {
    onResult(selectedImageIndices)
    viewModel.onCloseModal()
  }

  @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
    if recognizer.state == .ended || recognizer.state == .cancelled {
      scrollOnIndex = calculateImageIndex(on: collectionView.contentOffset.x)
      scrollTo(index: scrollOnIndex)
    }
  }

  @objc private func handleSwipeRecognizer(_  recognizer: UISwipeGestureRecognizer) {
    if recognizer.state != .ended {
      return
    }
    if recognizer.direction != .left && recognizer.direction != .right {
      return
    }
    let scrollToIndex = recognizer.direction == .right
      ? activeIndex + 1
      : activeIndex - 1
    scrollTo(index: scrollToIndex)
  }

  private func scrollTo(index: Int) {
    if index < 0 || index > assets.count - 1 {
      return
    }
    collectionView.scrollToItem(
      at: IndexPath(item: index, section: 0),
      at: .centeredHorizontally,
      animated: true
    )
    activeIndex = index
  }

  @objc private func onSelectImage() {
    if let selectedImageIndex = selectedImageIndices.firstIndex(of: scrollOnIndex) {
      selectedImageIndices.remove(at: selectedImageIndex)
      if let cell = collectionView.cellForItem(at: IndexPath(item: scrollOnIndex, section: 0)) as? ImageViewCell {
        cell.selectedCount = nil
        imagesPreviewView?.selectButton.clearCount()
      }
    } else {
      selectedImageIndices.append(scrollOnIndex)
      if let cell = collectionView.cellForItem(at: IndexPath(item: scrollOnIndex, section: 0)) as? ImageViewCell {
        cell.selectedCount = selectedImageIndices.count
        imagesPreviewView?.selectButton.setCount(selectedImageIndices.count)
      }
    }
  }

  private func calculateImageIndex(on scrollOffset: CGFloat) -> Int {
    let itemWidth = UIScreen.main.bounds.width
    let itemsInScrollOffset = collectionView.contentOffset.x / itemWidth
    let scrollOnIndex = itemsInScrollOffset.rounded(.towardZero)
    let scrollDistance = (itemsInScrollOffset - scrollOnIndex) * itemWidth
    let minScrollDistance = itemWidth / 2
    return Int(scrollOnIndex) + 1 > activeIndex
      ? scrollDistance > minScrollDistance
        ? activeIndex + 1
        : activeIndex
      : itemWidth - scrollDistance > minScrollDistance
        ? activeIndex - 1
        : activeIndex
  }
	
	private func requestImage(for asset: PHAsset, onResult: @escaping (UIImage?) -> Void) {
		imageManager.requestImage(
			for: asset,
			targetSize: imageSize,
			contentMode: .aspectFill,
			options: imageRequestOptions,
			resultHandler: { image, _ in onResult(image) }
		)
	}
}

extension ImagesPreviewVC: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return assets.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "ImageViewCell",
      for: indexPath
      ) as? ImageViewCell ?? ImageViewCell()
		requestImage(for: assets.object(at: indexPath.item), onResult: { image in
			guard let image = image else { return }
			cell.setImage(image: image)
		})
    if let index = selectedImageIndices.firstIndex(of: indexPath.item) {
      cell.selectedCount = index + 1
    }
    cell.previewImageView.hero.id = indexPath.item.description
    return cell
  }
}

extension ImagesPreviewVC: UICollectionViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    activeIndex = calculateImageIndex(on: scrollView.contentOffset.x)
    let indexPath = IndexPath(item: activeIndex, section: 0)
    guard let cell = collectionView.cellForItem(at: indexPath) as? ImageViewCell else {
      return
    }
    cell.selectedCount.foldL(
      none: { imagesPreviewView?.selectButton.clearCount() },
      some: { v in
        imagesPreviewView?.selectButton.setCount(v)
      }
    )
  }
}
