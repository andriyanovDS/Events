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
import Promises

struct SharedImage {
	let index: Int
	let image: UIImage
  let isICloudAsset: Bool
}

private let SWIPE_VELOCITY: CGFloat = 400
private let VERTICAL_TRANSLATION_BOUND: CGFloat = 75.0

class ImagesPreviewVC: UIViewControllerWithActivityIndicator {
  private var imagesPreviewView: ImagesPreviewView?
  private var activeCellIndex: Int = 0
	private let sharedImage: SharedImage
  private var selectedImageIndices: [Int]
  private let onImageDidSelected: (Int) -> Void
  private let viewModel: ImagesPreviewViewModel
  private let collectionView: UICollectionView
	private var isInitialOffsetDidSet: Bool = false
  private var isVerticalGestureActive: Bool = false
  private var lastTranslationY: CGFloat = 0.0
  private var feedbackGenerator: UISelectionFeedbackGenerator?

  init(
		viewModel: ImagesPreviewViewModel,
		sharedImage: SharedImage,
		selectedImageIndices: [Int],
		onImageDidSelected: @escaping (Int) -> Void
  ) {
    self.viewModel = viewModel
		self.sharedImage = sharedImage
		activeCellIndex = sharedImage.index
    self.selectedImageIndices = selectedImageIndices
    self.onImageDidSelected = onImageDidSelected
    collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
    super.init(nibName: nil, bundle: nil)

    viewModel.delegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let layout = ImagePickerCollectionViewLayout(
      cellSize: CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height
      )
    )
		layout.scrollDirection = .horizontal
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.collectionViewLayout = layout
    collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: "ImageViewCell")
    collectionView.panGestureRecognizer.addTarget(self, action: #selector(handleHorizontalPanGesture))
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleVerticalPanGesture))
    panGestureRecognizer.delegate = self
    collectionView.addGestureRecognizer(panGestureRecognizer)
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePressCollectionView))
    collectionView.addGestureRecognizer(tapGestureRecognizer)
    sutupView()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

		if !isInitialOffsetDidSet && sharedImage.index > 0 {
			scrollTo(index: sharedImage.index)
			isInitialOffsetDidSet = true
    }
  }

  private func sutupView() {
    imagesPreviewView = ImagesPreviewView(collectionView: collectionView)
    view = imagesPreviewView
    if let selectedImageIndex = selectedImageIndices.firstIndex(of: activeCellIndex) {
      imagesPreviewView?.selectButton.setCount(selectedImageIndex + 1)
    }
    imagesPreviewView?.selectButton.addTarget(self, action: #selector(onSelectImage), for: .touchUpInside)
    imagesPreviewView?.backButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
  }

  @objc private func closeModal() {
    viewModel.onCloseModal()
  }

  private func panGestureEnded(translationY: CGFloat, view: UIView) {
     if !isVerticalGestureActive { return }

     isVerticalGestureActive = false
     if abs(translationY) > VERTICAL_TRANSLATION_BOUND {
       view.topConstraint?.constant = (view.topConstraint?.constant ?? 0) + translationY
       closeModal()
       return
     }

     UIView.animate(
       withDuration: 0.3,
       animations: {
        view.transform = .identity
       }
     )
   }

  @objc private func handleVerticalPanGesture(_ recognizer: UIPanGestureRecognizer) {
    let activeCellIndexPath = IndexPath(item: activeCellIndex, section: 0)
    guard let cell = collectionView.cellForItem(at: activeCellIndexPath) else { return }
    let translation = recognizer.translation(in: view)

    switch recognizer.state {
    case .began:
      isVerticalGestureActive = true
      feedbackGenerator = UISelectionFeedbackGenerator()
      feedbackGenerator?.prepare()
    case .changed:
      let translationYAbs = abs(translation.y)
      cell.transform = CGAffineTransform(translationX: 0, y: translation.y)
      let alpha = 1 - translationYAbs / view.bounds.height
      view.backgroundColor = view.backgroundColor?.withAlphaComponent(alpha)
      if
        (lastTranslationY > VERTICAL_TRANSLATION_BOUND && translationYAbs < VERTICAL_TRANSLATION_BOUND)
        || (translationYAbs > VERTICAL_TRANSLATION_BOUND && lastTranslationY < VERTICAL_TRANSLATION_BOUND)
      {
        feedbackGenerator?.selectionChanged()
        feedbackGenerator?.prepare()
        lastTranslationY = translationYAbs
      }
    case .cancelled, .ended:
      feedbackGenerator = nil
      lastTranslationY = 0.0
      panGestureEnded(translationY: translation.y, view: cell)
    default:
      break
    }
  }

  @objc private func handleHorizontalPanGesture(_ recognizer: UIPanGestureRecognizer) {
    if recognizer.state == .ended || recognizer.state == .cancelled {
			let velocity = recognizer.velocity(in: view).x
			if abs(velocity) >= SWIPE_VELOCITY {
				let index = velocity > 0
					? activeCellIndex - 1
					: activeCellIndex + 1
				scrollTo(index: index)
				return
			}
			guard let index = nextActiveCellIndex() else { return }
			scrollTo(index: index)
    }
  }

  @objc private func handlePressCollectionView(_ recognizer: UITapGestureRecognizer) {
    if recognizer.state == .ended {
      onSelectImage()
    }
  }

  private func scrollTo(index: Int) {
    if index < 0 || index > viewModel.assetsCount - 1 {
      return
    }
    collectionView.isUserInteractionEnabled = false
    collectionView.scrollToItem(
      at: IndexPath(item: index, section: 0),
      at: .centeredHorizontally,
      animated: true
    )
  }

  @objc private func onSelectImage() {
    if let selectedImageIndex = selectedImageIndices.firstIndex(of: activeCellIndex) {
      selectedImageIndices.remove(at: selectedImageIndex)
      if let cell = collectionView.cellForItem(at: IndexPath(item: activeCellIndex, section: 0)) as? ImageViewCell {
        cell.selectedCount = nil
        imagesPreviewView?.selectButton.clearCount()
      }
    } else {
      selectedImageIndices.append(activeCellIndex)
      if let cell = collectionView.cellForItem(at: IndexPath(item: activeCellIndex, section: 0)) as? ImageViewCell {
        cell.selectedCount = selectedImageIndices.count
        imagesPreviewView?.selectButton.setCount(selectedImageIndices.count)
      }
    }
    onImageDidSelected(activeCellIndex)
  }

  private func nextActiveCellIndex() -> Int? {
    let offset = collectionView.contentOffset
		guard let scrollAtIndexPath = collectionView.indexPathForItem(at: offset) else {
			return nil
		}
		let scrollDistance = collectionView
			.layoutAttributesForItem(at: IndexPath(item: activeCellIndex, section: 0))
			.map { abs(offset.x - $0.frame.minX) }
		
		guard let distance = scrollDistance else {
			return nil
		}
		
		return distance > collectionView.bounds.width / 4.0
			? scrollAtIndexPath.item >= activeCellIndex
				? activeCellIndex + 1
				: activeCellIndex - 1
			: activeCellIndex
  }
}

extension ImagesPreviewVC: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.assetsCount
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "ImageViewCell",
      for: indexPath
			) as? ImageViewCell else {
				fatalError("Unexpected cell")
		}

    if let index = selectedImageIndices.firstIndex(of: indexPath.item) {
      cell.selectedCount = index + 1
    }
    cell.previewImageView.hero.id = indexPath.item.description

    if sharedImage.index == indexPath.item {
      cell.setSharedImage(image: sharedImage.image)
      if !sharedImage.isICloudAsset {
        return cell
      }
    }

    let asset = viewModel.asset(at: indexPath.item)
    cell.assetIndentifier = asset.localIdentifier
    viewModel.image(for: asset, onResult: { image in
      guard cell.assetIndentifier == asset.localIdentifier else { return }
      cell.setImage(image: image)
    })
    return cell
  }
}

extension ImagesPreviewVC: UICollectionViewDelegate {
	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    collectionView.isUserInteractionEnabled = true
		guard let indexPath = collectionView.indexPathForItem(at: scrollView.contentOffset) else {
			return
		}
		activeCellIndex = indexPath.item
	}

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard let activeIndex = nextActiveCellIndex() else { return }
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

extension ImagesPreviewVC: ImagesPreviewViewModelDelegate {
  func showImageLoadingProgress() {
    showActivityIndicator(for: view)
  }

  func hideImageLoadingProgress() {
    removeActivityIndicator()
  }
}

extension ImagesPreviewVC: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
      return false
    }
    let velocity = panGestureRecognizer.velocity(in: view)
    return abs(velocity.y) > abs(velocity.x)
  }
}
