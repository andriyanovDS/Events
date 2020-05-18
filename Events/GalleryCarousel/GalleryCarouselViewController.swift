//
//  GalleryCarouselViewController.swift
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
import RxCocoa
import RxSwift

class GalleryCarouselViewController: UIViewControllerWithActivityIndicator {
  typealias DataSource = FetchResultDataSource<GalleryCarouselCell>
  
  let viewModel: GalleryCarouselViewModel
  private let dataSource: DataSource
  private let sharedImage: SharedImage
  private var activeCellIndex: Int
  private let disposeBag = DisposeBag()
  private let onImageDidSelected: (Int) -> Void
  private var imagesPreviewView: GalleryCarouselView!
  private var isInitialOffsetDidSet: Bool = false
  private var collectionView: UICollectionView {
    imagesPreviewView.collectionView
  }
  private var interactiveTransition: InteractiveTransitioning!
  private var drawer: Drawer?

  init(
    viewModel: GalleryCarouselViewModel,
    sharedImage: SharedImage,
    dataSource: DataSource,
    onAssetDidSelected: @escaping (Int) -> Void
  ) {
    self.viewModel = viewModel
    self.sharedImage = sharedImage
    self.dataSource = dataSource
    self.onImageDidSelected = onAssetDidSelected
    activeCellIndex = sharedImage.index
    super.init(nibName: nil, bundle: nil)
    
    dataSource.changeTargetSize(UIScreen.main.bounds.size)
    dataSource.cellConfigurator = {[unowned self] (index, cell) in
      self.configure(cell: cell, at: index)
    }
    dataSource.cellImageSetter = {[unowned self] (image, index, cell) in
      guard index != self.sharedImage.index else { return }
      cell.setImage(image)
    }
    
    dataSource.imageRequestOptions?.progressHandler = {[weak self] progress, error, _, _ in
      DispatchQueue.main.async {
        if progress != 1.0 {
          self?.showActivityIndicator(for: nil)
          return
        }
        if progress == 1.0 || error != nil {
          self?.removeActivityIndicator()
        }
      }
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

		if !isInitialOffsetDidSet && sharedImage.index > 0 {
			scrollTo(index: sharedImage.index)
			isInitialOffsetDidSet = true
    }
  }

  private func setupView() {
    let view = GalleryCarouselView()
    view.collectionView.dataSource = dataSource
    view.collectionView.delegate = self
    view.collectionView.register(
      GalleryCarouselCell.self,
      forCellWithReuseIdentifier: GalleryCarouselCell.reuseIdentifier
    )
    view.setupActions(actions: EditingAction.allCases) {[unowned self] action in
      self.handleEditingAction(action)
    }
    view.collectionView.panGestureRecognizer.addTarget(self, action: #selector(handleHorizontalPanGesture))
    
    interactiveTransition = InteractiveTransitioning(
      view: view.collectionView,
      onFinish: {[unowned self] in self.closeModal() },
      activeViewProvider: {[unowned self] in
        let activeCellIndexPath = IndexPath(item: self.activeCellIndex, section: 0)
        return self.collectionView.cellForItem(at: activeCellIndexPath)!
      }
    )
    interactiveTransition.delegate = self
    interactiveTransition.translationYBound = Constants.translationYBound
    
    if let selectedImageIndex = dataSource.selectedAssetIndices.firstIndex(of: activeCellIndex) {
      view.selectButton.count = selectedImageIndex + 1
    }
    view.selectButton.rx.tap
      .subscribe(onNext: {[unowned self] _ in
        self.activeAssetDidSelected()
      })
      .disposed(by: disposeBag)
    view.backButton.rx.tap
      .subscribe(onNext: {[unowned self] _ in
        self.closeModal()
      })
      .disposed(by: disposeBag)
    
    view.collectionView.rx.contentOffset
      .map { $0.x }
      .pairwise()
      .filter { self.isInsideBounds($0.0) != self.isInsideBounds($0.1)}
      .subscribe(onNext: {[unowned self] _ in
        let index = self.nextActiveCellIndex()
        let selectionIndex = self.dataSource.selectionIndex(forAssetAt: index)
        self.imagesPreviewView.selectButton.count = selectionIndex.map { $0 + 1 }
      })
      .disposed(by: disposeBag)
    
    self.view = view
    imagesPreviewView = view
  }

  private func handleEditingAction(_ action: EditingAction) {
    switch action {
    case .brush:
      guard drawer == nil else { return }
      let cell = collectionView.cellForItem(at: IndexPath(item: activeCellIndex, section: 0))
      guard
        let galleryCell = cell as? GalleryCarouselCell,
        let image = galleryCell.previewImageView.image
      else { return }
      imagesPreviewView.changeAccessoryViewsVisibility(isHidden: true)
      drawer = Drawer(
        size: galleryCell.previewImageView.frame.size,
        image: image,
        containerView: view
      ) {[weak galleryCell, unowned self] image in
        guard let cell = galleryCell else { return }
        self.drawingDidComplete(with: image, forCell: cell)
      }
      collectionView.isScrollEnabled = false
      interactiveTransition.isTransitionEnabled = false
    }
  }
  
  private func drawingDidComplete(with image: UIImage?, forCell cell: GalleryCarouselCell) {
    if let image = image {
      cell.previewImageView.image = image
    }
    drawer = nil
    imagesPreviewView.changeAccessoryViewsVisibility(isHidden: false)
    collectionView.isScrollEnabled = true
    interactiveTransition.isTransitionEnabled = true
  }
  
  private func movementDistance(at offsetX: CGFloat) -> CGFloat {
    let indexPath = IndexPath(item: activeCellIndex, section: 0)
    let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)!
    return offsetX - attributes.frame.minX
  }
  
  private func isInsideBounds(_ offsetX: CGFloat) -> Bool {
    let width = collectionView.bounds.width
    return abs(movementDistance(at: offsetX)) > width / 4
  }
  
  private func configure(cell: GalleryCarouselCell, at index: Int) {
    cell.previewImageView.hero.id = index.description
    if sharedImage.index == index {
      cell.setImage(sharedImage.image)
    }
  }

  private func closeModal() {
    viewModel.onClose()
  }
  
  private func activeAssetDidSelected() {
    let previousCount = dataSource.selectedAssetIndices.count
    dataSource.selectAsset(at: activeCellIndex)
    let currentCount = dataSource.selectedAssetIndices.count
    
    if previousCount > currentCount {
      imagesPreviewView.selectButton.count = nil
    } else {
      imagesPreviewView.selectButton.count = currentCount
    }
    onImageDidSelected(activeCellIndex)
  }

  @objc private func handleHorizontalPanGesture(_ recognizer: UIPanGestureRecognizer) {
    if recognizer.state == .ended || recognizer.state == .cancelled {
			let velocity = recognizer.velocity(in: view).x
      if abs(velocity) >= Constants.swipeVelocity {
        let index = nextCellIndex(in: velocity > 0 ? .left : .right)
				scrollTo(index: index)
				return
			}
			scrollTo(index: nextActiveCellIndex())
    }
  }

  private func scrollTo(index: Int) {
    imagesPreviewView.collectionView.isUserInteractionEnabled = false
    imagesPreviewView.collectionView.scrollToItem(
      at: IndexPath(item: index, section: 0),
      at: .centeredHorizontally,
      animated: true
    )
  }
  
  private func nextCellIndex(in direction: Direction) -> Int {
    switch direction {
    case .left:
      return activeCellIndex == 0
        ? activeCellIndex
        : activeCellIndex - 1
    case .right:
      return activeCellIndex == dataSource.assets.count - 1
        ? activeCellIndex
        : activeCellIndex + 1
    }
  }

  private func nextActiveCellIndex() -> Int {
    let width = collectionView.bounds.width
    let distance = movementDistance(at: collectionView.contentOffset.x)
    
    if abs(distance) < width / 4 {
      return activeCellIndex
    }
    return nextCellIndex(in: distance > 0 ? .right : .left)
  }
}

extension GalleryCarouselViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    activeAssetDidSelected()
  }

  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return drawer == nil
  }
  
	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    collectionView.isUserInteractionEnabled = true
		guard let indexPath = collectionView.indexPathForItem(at: scrollView.contentOffset) else {
			return
		}
		activeCellIndex = indexPath.item
	}
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let collectionView = scrollView as? UICollectionView else { return }
    dataSource.attemptToCacheAssets(collectionView)
  }
}

extension GalleryCarouselViewController: InteractiveTransitioningDelegate {
  func applyActiveTranslation(_ translation: CGFloat, toActiveView view: UIView) {
    view.transform = CGAffineTransform(translationX: 0, y: translation)
    let alpha = 1 - abs(translation) / view.bounds.height
    self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(alpha)
  }
  
  func applyFinishTranslation(_ translation: CGFloat, toActiveView view: UIView) {
    let center = view.center
    view.center = CGPoint(x: center.x, y: center.y + translation)
    view.transform = .identity
  }
  
  func applyIdentityTranslation(toActiveView view: UIView) {
    view.transform = .identity
    self.view.backgroundColor = .backgroundInverted
  }
}

extension GalleryCarouselViewController {
  struct Constants {
    static let swipeVelocity: CGFloat = 400.0
    static let translationYBound: CGFloat = 75.0
  }
  
  enum Direction {
    case left
    case right
  }
}

enum EditingAction: CaseIterable {
  case brush
}

extension EditingAction: GalleryCarouselViewAction {
  var icon: String {
    switch self {
    case .brush: return "brush"
    }
  }
}

struct SharedImage {
  let index: Int
  let image: UIImage
}
