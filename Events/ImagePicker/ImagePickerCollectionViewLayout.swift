//
//  ImagePickerCollectionViewLayout.swift
//  Events
//
//  Created by Дмитрий Андриянов on 13/10/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class ImagePickerCollectionViewLayout: UICollectionViewFlowLayout {
  // We need it to calculate collectionViewContentSize before cellSize changes to perform setContentOffset
  var cellWidthForContentSizeCalculation: CGFloat
  var previousAttributes: [UICollectionViewLayoutAttributes] = []
  var currentAttributes: [UICollectionViewLayoutAttributes] = []
  var cellSize: CGSize

  init(cellSize: CGSize) {
    self.cellSize = cellSize
    cellWidthForContentSizeCalculation = cellSize.width
    super.init()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var collectionViewContentSize: CGSize {
    let count = CGFloat(currentAttributes.count)
    return CGSize(
      width: (cellWidthForContentSizeCalculation + minimumInteritemSpacing) * count,
      height: cellSize.height
    )
  }

  override func prepare() {
    super.prepare()
    previousAttributes = currentAttributes
    currentAttributes = []
    guard let collectionView = collectionView else { return }
    let itemCount = collectionView.numberOfItems(inSection: 0)
    currentAttributes = Array(0..<itemCount)
      .map({ itemIndex in
        let indexPath = IndexPath(item: itemIndex, section: 0)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(
          x: (cellSize.width + minimumInteritemSpacing) * CGFloat(itemIndex),
          y: 0,
          width: cellSize.width,
          height: cellSize.height
        )
        return attributes
      })
  }

  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    if let oldBounds = collectionView?.bounds {
      return !oldBounds.equalTo(newBounds)
    }
    return false
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return currentAttributes
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return currentAttributes[indexPath.item]
  }

  override func initialLayoutAttributesForAppearingItem(
    at itemIndexPath: IndexPath
  ) -> UICollectionViewLayoutAttributes? {
    if previousAttributes.count < itemIndexPath.item + 1 {
      return nil
    }
    return previousAttributes[itemIndexPath.item]
  }

  override func finalLayoutAttributesForDisappearingItem(
    at itemIndexPath: IndexPath
  ) -> UICollectionViewLayoutAttributes? {
    return layoutAttributesForItem(at: itemIndexPath)
  }
}
