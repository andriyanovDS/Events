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

class ImagesPreviewVC: UIViewController {
  var imagesPreviewView: ImagesPreviewView?
  var activeIndex: Int
  let images: [UIImage]
  let onResult: ([UIImage]) -> Void
  let viewModel: ImagesPreviewViewModel
  let layout = UICollectionViewFlowLayout()
  let collectionView: UICollectionView

  init(
    viewModel: ImagesPreviewViewModel,
    images: [UIImage],
    startAt index: Int,
    onResult: @escaping ([UIImage]) -> Void
  ) {
    self.viewModel = viewModel
    self.images = images
    activeIndex = index
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
    collectionView.collectionViewLayout = layout
    collectionView.register(ImagePreviewCell.self, forCellWithReuseIdentifier: "ImagePreviewCell")

    let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRecognizer))
    collectionView.panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture))
    collectionView.addGestureRecognizer(swipeRecognizer)

    sutupView()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if activeIndex > 0 {
      collectionView.scrollToItem(
        at: IndexPath(item: activeIndex, section: 0),
        at: .centeredHorizontally,
        animated: false
      )
    }
  }

  private func sutupView() {
    imagesPreviewView = ImagesPreviewView(collectionView: collectionView)
    view = imagesPreviewView
    imagesPreviewView?.backButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
  }

  @objc private func closeModal() {
    viewModel.onCloseModal()
  }

  @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
    if recognizer.state == .ended || recognizer.state == .cancelled {
      let itemWidth = UIScreen.main.bounds.width
      let itemsInScrollOffset = collectionView.contentOffset.x / itemWidth
      let scrollOnIndex = itemsInScrollOffset.rounded(.towardZero)
      let scrollDistance = (itemsInScrollOffset - scrollOnIndex) * itemWidth
      let minScrollDistance = itemWidth / 4
      let scrollToIndex = Int(scrollOnIndex) + 1 > activeIndex
        ? scrollDistance > minScrollDistance
          ? activeIndex + 1
          : activeIndex
        : itemWidth - scrollDistance > minScrollDistance
          ? activeIndex - 1
          : activeIndex
      scrollTo(index: scrollToIndex)
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
    if index < 0 || index > images.count - 1 {
      return
    }
    collectionView.scrollToItem(
      at: IndexPath(item: index, section: 0),
      at: .centeredHorizontally,
      animated: true
    )
    activeIndex = index
  }
}

extension ImagesPreviewVC: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "ImagePreviewCell",
      for: indexPath
      ) as? ImagePreviewCell ?? ImagePreviewCell()
    let image = images[indexPath.item]
    cell.previewImageView.image = image
    cell.previewImageView.hero.id = indexPath.item.description
    return cell
  }
}
