//
//  ImagePickerView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class ImagePickerView: UIView {
  var actionsView: ImagePickerActionsView!
  let closeButton = UIButton()
  var state: ImagePickerState
  let collectionView: UICollectionView
  let backgroundView = UIView()
  private let dataSource: ImagePickerViewDataSource
  private let layout: ImagePickerCollectionViewLayout
  private let contentView = UIView()
  private let containerView = UIView()
  private let onSelectImageSource: (ImageSource) -> Void
  private let onConfirmSendImages: () -> Void
  
  struct Constants {
    static let imageSize = CGSize(width: 100, height: 90)
    static let actionButtonHeight: CGFloat = 50.0
  }

  init(
    dataSource: ImagePickerViewDataSource,
    onSelectImageSource: @escaping (ImageSource) -> Void,
    onConfirmSendImages: @escaping () -> Void
    ) {
    self.dataSource = dataSource
    self.onSelectImageSource = onSelectImageSource
    self.onConfirmSendImages = onConfirmSendImages
    let selectedAssetCount = dataSource.selectedAssetIndices.count
    state = .makeFromSelectedAssetsCount(selectedAssetCount)
    layout = ImagePickerCollectionViewLayout(cellSize: Constants.imageSize)
    collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func animateAppearance() {
    contentView.transform = CGAffineTransform(translationX: 0, y: contentView.frame.height)
    UIView.animate(withDuration: 0.2, animations: {
      self.contentView.transform = .identity
    })
  }

  func animateDisappearance(completion: @escaping () -> Void) {
    UIView.animate(
      withDuration: 0.2,
      animations: {
        self.contentView.transform = CGAffineTransform(
          translationX: 0,
          y: self.contentView.frame.height
        )
      },
      completion: { _ in completion() }
    )
  }

  func scrollToCell(at index: Int, scale: CGFloat) {
    let offset = contentOffset(forCellAt: index, scale: scale)
    collectionView.setContentOffset(offset, animated: scale == 1.0)
  }

  func showCollectionView() {
    let insets = collectionView.contentInset
    let collectionViewPreviewHeight = Constants.imageSize.height + insets.top + insets.bottom
    let collectionViewHeight = state == .preview
      ? collectionViewPreviewHeight
      : state.scale * collectionViewPreviewHeight
    collectionView.heightConstraint?.constant = collectionViewHeight
    collectionView.contentOffset = CGPoint(x: -insets.left, y: insets.top)
    layoutIfNeeded()
  }

  func onImageDidSelected(at index: Int) {
    let selectedAssetIndices = dataSource.selectedAssetIndices
    updateCellSelectionCount(selectedAssetIndices: selectedAssetIndices)
    let currentState = state
    state = .makeFromSelectedAssetsCount(selectedAssetIndices.count)
    changeFirstAction()

    if (state == .preview) != (currentState == .preview) {
      changeCollectionHeight(andFocusAt: index)
      return
    }
    self.scrollToCell(at: index, scale: 1.0)
  }

  private  func handleSelectedAction(_ action: ImagePickerActionsView.ImagePickerAction) {
    switch action {
    case .openCamera:
      onSelectImageSource(.camera)
    case .openLibrary:
      onSelectImageSource(.library)
    case .selectImages:
      onConfirmSendImages()
    }
  }

  private func setupView() {
    backgroundColor = .clear
    backgroundView.backgroundColor = UIColor.backgroundInverted.withAlphaComponent(0.4)
    setupCollectionView()
    setupCloseButton()

    actionsView = ImagePickerActionsView(actionHandler: {[unowned self] action in
      self.handleSelectedAction(action)
    })
    actionsView.setupActions(actions: ImageSource.allCases.map {
      ImagePickerActionsView.ImagePickerAction.makeActionByImageSource($0)
    })
    containerView.layer.cornerRadius = 10
    containerView.clipsToBounds = true
    containerView.sv(collectionView, actionsView)
    contentView.sv([containerView, closeButton])
    sv(backgroundView, contentView)

    contentView.left(10).right(10).Bottom == safeAreaLayoutGuide.Bottom
    closeButton.left(0).right(0).bottom(0).height(Constants.actionButtonHeight)
    collectionView.left(0).right(0).height(0).top(0).Bottom == actionsView.Top
    actionsView.left(0).right(0).bottom(0)
    containerView.left(0).right(0).top(0).Bottom == closeButton.Top - 15
    backgroundView.fillContainer()
  }

  private func setupCollectionView() {
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 6
    collectionView.style { v in
      v.contentInset = UIEdgeInsets(
        top: 5,
        left: 5,
        bottom: 5,
        right: 5
      )
      v.showsVerticalScrollIndicator = false
      v.showsHorizontalScrollIndicator = false
      v.backgroundColor = .background
      v.register(ImagePreviewCell.self, forCellWithReuseIdentifier: ImagePreviewCell.reuseIdentifier)
    }
  }

  private func setupCloseButton() {
    let closeButtonTitle = NSLocalizedString(
      "Close",
      comment: "Image picker: close"
    )
    styleText(
      button: closeButton,
      text: closeButtonTitle,
      size: 20,
      color: .blueButtonBackground,
      style: .bold
    )
    closeButton.backgroundColor = .background
    closeButton.layer.cornerRadius = 10
  }

  private func changeCollectionHeight(andFocusAt activeIndex: Int) {
    let scale = state.scale
    let transform = CGAffineTransform(scaleX: scale, y: scale)
    let imageSize = layout.cellSize.applying(transform)
    layout.cellWidthForContentSizeCalculation = imageSize.width
    if scale > 1 {
      layout.invalidateLayout()
      layoutIfNeeded()
    }
    layout.cellSize = imageSize
    UIView.animate(withDuration: 0.2, animations: {
      self.collectionView.heightConstraint?.constant *= scale
      self.scrollToCell(at: activeIndex, scale: scale)
      self.layoutIfNeeded()
    }, completion: { _ in
      self.adjustCellSelectionButtonHorizontally()
    })
  }

  private func changeFirstAction() {
    switch state {
    case .preview:
      actionsView.changeFirstAction(to: .openCamera)
    case .expanded(let selectedAssetsCount):
      actionsView.changeFirstAction(to: .selectImages(count: selectedAssetsCount))
    }
  }
}

extension ImagePickerView {
  func adjustCellSelectionButtonHorizontally() {
    let cells = collectionView.visibleCells.compactMap { $0 as? ImagePreviewCell }
    let padding = ImagePreviewCell.Constants.selectionButtonPadding
    let rightmostIndex = rightmostCellIndex()

    for cell in cells {
      let indexPath = collectionView.indexPath(for: cell)!
      if indexPath.item == rightmostIndex {
        let nextPosition = selectionButtonOffset(forCellAt: indexPath.item)
        if nextPosition != -cell.selectButtonRightPadding {
          cell.setSelectButtonPosition(nextPosition)
        }
        continue
      }
      if cell.selectButtonRightPadding == padding {
        continue
      }
      cell.setSelectButtonPosition(padding)
    }
  }

  func selectionButtonOffset(forCellAt index: Int) -> CGFloat {
    let cellWidth = layout.cellSize.width
    let padding = ImagePreviewCell.Constants.selectionButtonPadding
    let cellTotalWidth = cellWidth + layout.minimumInteritemSpacing
    let scrollViewMaxX = collectionView.contentOffset.x + collectionView.bounds.width
    let cellMaxX = (CGFloat(index) * cellTotalWidth) + cellWidth
    if scrollViewMaxX > cellMaxX {
      return padding
    }
    let offset = abs(scrollViewMaxX - cellMaxX)
    var resultOffset: CGFloat = offset
    if offset + ImagePreviewCell.Constants.selectionButtonSize > cellWidth - padding {
      resultOffset = cellWidth - padding - ImagePreviewCell.Constants.selectionButtonSize
    }
    if offset < padding {
      resultOffset = padding
    }
    return resultOffset
  }

  private func rightmostCellIndex() -> Int {
    let maxX = collectionView.contentOffset.x + collectionView.bounds.width
    let index = Int(maxX / (layout.cellSize.width + layout.minimumLineSpacing))

    let itemsInCollectionView = collectionView.numberOfItems(inSection: 0)
    if index >= itemsInCollectionView {
      return itemsInCollectionView - 1
    }
    return index
  }

  private func contentOffset(forCellAt index: Int, scale: CGFloat) -> CGPoint {
    let top = -collectionView.adjustedContentInset.top
    if scale == 1 {
      if index == 0 { return CGPoint(x: 0, y: top) }

      if index == collectionView.numberOfItems(inSection: 0) - 1 {
        return CGPoint(
          x: collectionView.contentSize.width - collectionView.bounds.width,
          y: top
        )
      }
    }

    let indexPath = IndexPath(item: index, section: 0)
    guard let attributes = collectionView.layoutAttributesForItem(at: indexPath) else {
      return CGPoint(
        x: collectionView.contentSize.width - collectionView.bounds.width,
        y: top
      )
    }
    let frame = attributes.frame
    let totalSpacingWidth = CGFloat(index) * layout.minimumInteritemSpacing
    let scaledMinX = (abs(frame.minX) - totalSpacingWidth) * scale + totalSpacingWidth
    let imageCenterX = scaledMinX + (frame.width * scale) / 2
    return CGPoint(
      x: imageCenterX - collectionView.bounds.width / 2,
      y: top
    )
  }

  private func updateCellSelectionCount(selectedAssetIndices: [Int]) {
    let cells = collectionView.visibleCells.compactMap { $0 as? ImagePreviewCell }
    
    for cell in cells {
      let indexPath = collectionView.indexPath(for: cell)!
      let selectionIndex = selectedAssetIndices.firstIndex(of: indexPath.item).map { $0 + 1 }
      cell.setSelectionCount(selectionIndex)
    }
  }
}

enum ImagePickerState: Equatable {
  case preview, expanded(selectedAssetsCount: Int)

  static func makeFromSelectedAssetsCount(_ count: Int) -> Self {
    count == 0 ? .preview : .expanded(selectedAssetsCount: count)
  }

  var scale: CGFloat {
    let ratio = ImagePickerView.Constants.actionButtonHeight / ImagePickerView.Constants.imageSize.width
    switch self {
    case .preview:
      return 1 / (1 + ratio)
    case .expanded:
      return 1 + ratio
    }
  }
}

protocol ImagePickerViewDataSource: class {
  var selectedAssetIndices: [Int] { get }
}
