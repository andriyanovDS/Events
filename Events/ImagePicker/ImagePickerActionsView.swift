//
//  ImagePickerActionsView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 26/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import Hero

let IMAGES_STACK_VIEW_SPACING: CGFloat = 6.0

class ImagePickerActionsView: UIView {
  let collectionView: UICollectionView
  let actionsStackView = UIStackView()
  let layout = ImagePickerCollectionViewLayout()
  var actions: [ImagePickerItem] = []
  weak var delegate: ImagePickerActionsViewDelegate?

  init() {
    collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
    super.init(frame: CGRect.zero)
    setupView()
  }

  struct ScrollToWithTimeout {
    let sctollTo: CGFloat
    let timeout: Double
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

   func setupActions() {
    ImageSource.allCases.enumerated().forEach { index, source in
      let button = ImagePickerItem(
        action: source == .camera
          ? ImagePickerAction.openCamera
          : ImagePickerAction.openLibrary,
        labelText: source.localizedString(),
        isBoldLabel: false,
        hasBorder: index == 0
      )
      button.addTarget(self, action: #selector(onActionDidSelected), for: .touchUpInside)
      button.height(PICKER_ACTION_BUTTON_HEIGHT)
      actionsStackView.addArrangedSubview(button)
      actions.append(button)
    }
  }

  func scrollToSelectedImageView(at index: Int, scale: CGFloat) -> CGFloat {
    let point = contentOffsetPoint(for: index, scale: scale)
    collectionView.setContentOffset(point, animated: scale == 1.0)
    return point.x
  }

  func selectButtonOffset(forCellAt index: Int, contentOffsetX: CGFloat) -> CGFloat {
    let cellWidth = layout.cellSize.width
    let cellTotalWidth = cellWidth + IMAGES_STACK_VIEW_SPACING
    let scrollViewMaxX = contentOffsetX + collectionView.bounds.width
    let cellMaxX = (CGFloat(index) * cellTotalWidth) + cellWidth
    if scrollViewMaxX > cellMaxX {
      return SELECT_BUTTON_PADDING
    }
    let offset = abs(scrollViewMaxX - cellMaxX)
    var resultOffset: CGFloat = offset
    if offset + SELECT_BUTTON_SIZE > cellWidth - SELECT_BUTTON_PADDING {
      resultOffset = cellWidth - SELECT_BUTTON_PADDING - SELECT_BUTTON_SIZE
    }
    if offset < SELECT_BUTTON_PADDING {
      resultOffset = SELECT_BUTTON_PADDING
    }
    return resultOffset
  }

  func adjustImageViewSelectButton(contentOffsetX: CGFloat) {
    let indexPath = IndexPath(
      item: rightmostImageViewIndex(contentOffsetX: contentOffsetX),
      section: 0
    )
    guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePreviewCell else {
      collectionView.visibleCells
        .compactMap { $0 as? ImagePreviewCell }
        .filter { $0.selectButton.rightConstraint?.constant != -SELECT_BUTTON_PADDING }
        .forEach { $0.setSelectButtonPosition(SELECT_BUTTON_PADDING) }
      return
    }
    cell.setSelectButtonPosition(
      selectButtonOffset(forCellAt: indexPath.item, contentOffsetX: contentOffsetX)
    )
    collectionView.visibleCells
      .compactMap { $0 as? ImagePreviewCell }
      .filter { $0 != cell && $0.selectButton.rightConstraint?.constant != -SELECT_BUTTON_PADDING }
      .forEach { $0.setSelectButtonPosition(SELECT_BUTTON_PADDING) }
  }

  func adjustImageViewSelectButtonAfterScroll() {
    adjustImageViewSelectButton(contentOffsetX: collectionView.contentOffset.x)
  }

  private func contentOffsetPoint(for index: Int, scale: CGFloat) -> CGPoint {
    let top = -collectionView.adjustedContentInset.top
    if scale == 1 {
      if index == 0 {
        return CGPoint(
          x: 0,
          y: top
        )
      }

      if index == collectionView.numberOfItems(inSection: 0) - 1 {
        return CGPoint(
          x: collectionView.contentSize.width - collectionView.bounds.width,
          y: top
        )
      }
    }

    let indexPath = IndexPath(
      item: index,
      section: 0
    )
    guard let attributes = collectionView.layoutAttributesForItem(at: indexPath) else {
      return CGPoint(
        x: collectionView.contentSize.width - collectionView.bounds.width,
        y: top
      )
    }
    let frame = attributes.frame
    let imageCenterX: CGFloat = abs(frame.minX) + frame.width / 2
    return CGPoint(
      x: imageCenterX * scale - collectionView.bounds.width / 2,
      y: top
    )
  }

  @objc func onActionDidSelected(_ item: ImagePickerItem) {
    delegate?.onSelectAction(item.action)
  }

  private func setupView() {
    clipsToBounds = true
    layer.cornerRadius = 10
    layout.scrollDirection = .horizontal
    layout.cellSize = CGSize(
      width: PICKER_IMAGE_WIDTH,
      height: PICKER_IMAGE_HEIGHT
    )
    layout.minimumInteritemSpacing = IMAGES_STACK_VIEW_SPACING
    collectionView.style({ v in
      v.contentInset = UIEdgeInsets(
        top: 7,
        left: 10,
        bottom: 0,
        right: 10
      )
      v.showsVerticalScrollIndicator = false
      v.showsHorizontalScrollIndicator = false
      v.backgroundColor = .white
      v.collectionViewLayout = layout
      v.register(ImagePreviewCell.self, forCellWithReuseIdentifier: "ImagePreviewCell")
      
    })
    actionsStackView.style({ v in
      v.axis = .vertical
      v.alignment = .fill
      v.distribution = .fillProportionally
    })

    setupActions()
    sv(collectionView, actionsStackView)
    setupConstraints()
  }

  private func setupConstraints() {
    actionsStackView.left(0).right(0)
    collectionView.height(100).left(0).right(0).top(0)
    actionsStackView.Top == collectionView.Bottom
  }

  private func rightmostImageViewIndex(contentOffsetX: CGFloat) -> Int {
    let maxX = contentOffsetX + collectionView.bounds.width
    let imagesCount = maxX / (layout.cellSize.width + IMAGES_STACK_VIEW_SPACING)
    let index = Int(imagesCount.rounded(.down))

    let itemsInCollectionView = collectionView.numberOfItems(inSection: 0)
    if index >= itemsInCollectionView {
      return itemsInCollectionView - 1
    }
    return index
  }
}

protocol ImagePickerActionsViewDelegate: class {
  var state: ImagePickerState { get }
  func onSelectAction(_: ImagePickerAction) -> Void
}
