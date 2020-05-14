//
//  ImagePickerVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Photos

class ImagePickerVC: UIViewController, ViewModelBased {
  var viewModel: ImagePickerViewModel!
  private var imagePickerView: ImagePickerView!
  private var dataSource: ImagePickerDataSource!
  private var isAppearanceAnimationPerformed: Bool = false

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = ImagePickerDataSource(
      cellConfigurator: {[unowned self] (configuration, cell) in
        self.configure(cell: cell, with: configuration)
      }
    )
    dataSource.changeTargetSize(ImagePickerView.Constants.imageSize)
    setupView()    
    viewModel.delegate = self
    viewModel.onViewReady()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !isAppearanceAnimationPerformed {
      imagePickerView.animateAppearance()
      isAppearanceAnimationPerformed = true
    }
  }

  private func setupView() {
    imagePickerView = ImagePickerView(
      dataSource: dataSource,
      onSelectImageSource: {[unowned self] source in
        self.viewModel.onSelectImageSource(source: source)
      },
      onConfirmSendImages: {[unowned self] in
        self.imagePickerView.animateDisappearance(
          completion: {[weak self] in
            guard let self = self else { return }
            self.viewModel.confirmSelectedAssets(self.dataSource.selectedAssets)
          }
        )
      }
    )
    imagePickerView.collectionView.delegate = self
    imagePickerView.collectionView.dataSource = dataSource
    imagePickerView.closeButton.addTarget(
      self,
      action: #selector(onClose),
      for: .touchUpInside
    )
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapBackgroundView(_:)))
    imagePickerView.backgroundView.addGestureRecognizer(tapGestureRecognizer)
    view = imagePickerView
  }

  @objc func onClose() {
    imagePickerView.animateDisappearance(
      completion: {[weak self] in
        guard let self = self else { return }
        self.viewModel.confirmSelectedAssets(self.dataSource.initialSelectedAssets)
      }
    )
  }

  @objc func onTapBackgroundView(_ recognizer: UITapGestureRecognizer) {
    if recognizer.state == .ended {
      onClose()
    }
  }

  private func selectAsset(at index: Int) {
    dataSource.selectAsset(at: index)
    let collectionView = imagePickerView.collectionView
    let cellIndexPath = IndexPath(item: index, section: 0)
    if collectionView.cellForItem(at: cellIndexPath) == nil {
      collectionView.scrollToItem(at: cellIndexPath, at: .centeredHorizontally, animated: false)
    }
    imagePickerView.onImageDidSelected(at: index)
  }
}

extension ImagePickerVC: ImagePickerViewModelDelegate {
  func viewModel(
    _: ImagePickerViewModel,
    didLoadAssets assets: PHFetchResult<PHAsset>,
    whereSelected indices: [Int]
  ) {
    dataSource.updateAssets(assets, whereSelected: indices)
    imagePickerView.showCollectionView()
    imagePickerView.collectionView.reloadData()
  }

  func viewModel(_: ImagePickerViewModel, didSelectImageAt index: Int) {
    selectAsset(at: index)
  }
}

extension ImagePickerVC {
  private func configure(
    cell: ImagePreviewCell,
    with configuration: ImagePickerDataSource.CellConfiguration
  ) {
    cell.assetIdentifier = configuration.assetIdentifier
    if let selectedPosition = configuration.selectedPosition {
      cell.selectionCount = selectedPosition
    }
    cell.previewImageView.hero.id = configuration.index.description
    cell.onPressSelectButton = {[unowned self] in
      self.selectAsset(at: configuration.index)
    }
   
    let selectButtonOffset = imagePickerView.selectionButtonOffset(forCellAt: configuration.index)
    cell.setSelectButtonPosition(selectButtonOffset)
  }
}

extension ImagePickerVC: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    dataSource.loadSharedImage(forAssetAt: indexPath.item, completion: {[weak self] sharedImage in
      guard let self = self, let sharedImage = sharedImage else { return }

      self.viewModel.openImagesPreview(
        with: self.dataSource.assets,
        whereSelected: self.dataSource.selectedAssetIndices,
        startAt: indexPath.item,
        sharedImage: sharedImage
      )
    })
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    imagePickerView?.adjustCellSelectionButtonHorizontally()
		guard let collectionView = scrollView as? UICollectionView else { return }
		dataSource.attemptToCacheAssets(collectionView)
  }
}
