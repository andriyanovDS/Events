//
//  DescriptionCollectionViewDelegate.swift
//  Events
//
//  Created by Dmitry on 05.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class DescriptionCollectionViewDelegate: NSObject, UICollectionViewDelegate {
  
  private let updateView: () -> Void
  private let dataSource: DescriptionDataSource
  
  init(
    dataSource: DescriptionDataSource,
    updateView: @escaping () -> Void
  ) {
    self.dataSource = dataSource
    self.updateView = updateView
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.item == dataSource.activeDescriptionIndex { return }
    
    guard let cell = collectionView.cellForItem(at: indexPath) as? DescriptionCellView else { return }
    dataSource.selectDescription(at: indexPath.item)
    cell.selectAnimation.startAnimation()
    collectionView
      .visibleCells
      .compactMap { $0 as? DescriptionCellView }
      .filter { $0.isActive }
      .forEach { $0.isActive = false }
    cell.isActive = true
    updateView()
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }
}
