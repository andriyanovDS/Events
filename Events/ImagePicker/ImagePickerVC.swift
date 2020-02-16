//
//  ImagePickerVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Photos

class ImagePickerVC: UIViewController {
  weak var viewModel: ImagePickerViewModel!
  var imagePickerView: ImagePickerView?

  init(viewModel: ImagePickerViewModel) {
    self.viewModel = viewModel
    let scale = UIScreen.main.scale
    viewModel.targetSize = CGSize(
      width: PICKER_IMAGE_MAX_SIZE * scale,
      height: PICKER_IMAGE_MAX_SIZE * scale
    )
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    viewModel.delegate = self
    viewModel.onViewReady()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.imagePickerView?.animateShowContent()
    }
  }

  private func onSelectImageSource(source: ImageSource) {
    viewModel.onSelectImageSource(source: source)
  }

  private func onConfirmSendImages() {
    viewModel.onConfirmSendImages()
  }

  private func setupView() {
    imagePickerView = ImagePickerView(
      onSelectImageSource: {[unowned self] source in
        self.onSelectImageSource(source: source)
      },
      onConfirmSendImages: {[unowned self] in
        self.onConfirmSendImages()
      }
    )
    imagePickerView?.actionsView.collectionView.delegate = self
    imagePickerView?.actionsView.collectionView.dataSource = self
    imagePickerView?.closeButton.addTarget(
      self,
      action: #selector(onClose),
      for: .touchUpInside
    )
    view = imagePickerView
  }

  @objc func onClose() {
    imagePickerView?.animateHideContent(onComplete: {[unowned self] in
      self.viewModel?.closeImagePicker(with: [])
    })
  }

  @objc private func onPressSelectButton(_ button: SelectImageButton) {
    let index = button.tag
    viewModel.onSelectImage(at: index)
  }
}

extension ImagePickerVC: ImagePickerViewModelDelegate {
  func onImageDidSelected(at index: Int) {
    guard let collectionView = imagePickerView?.actionsView.collectionView else { return }
    let indexPath = IndexPath(item: index, section: 0)
    guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePreviewCell else {
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
      imagePickerView?.onImageDidSelected(at: index, selectedImageIndices: viewModel.selectedImageIndices)
      return
    }
    cell.selectButton.setCount(viewModel.selectedImageIndices.count)
    imagePickerView?.onImageDidSelected(at: index, selectedImageIndices: viewModel.selectedImageIndices)
  }

  func performCloseAnimation(onComplete: @escaping () -> Void) {
    imagePickerView?.animateHideContent(onComplete: onComplete)
  }

  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
    defer {
      self.dismiss(animated: true, completion: nil)
    }
		
    guard let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset else {
      return
    }
    viewModel.closeImagePicker(with: [asset])
  }

  func updateImagePreviews(selectedImageIndices: [Int]) {
    imagePickerView?.updateImagePreviews(selectedImageIndices: selectedImageIndices)
  }
}

extension ImagePickerVC: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.assetsCount
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "ImagePreviewCell",
      for: indexPath
      ) as? ImagePreviewCell else {
        fatalError("unexpected cell in collection view")
    }
    let asset = viewModel.asset(at: indexPath.item)
    cell.assetIndentifier = asset.localIdentifier
    cell.selectButton.addTarget(self, action: #selector(onPressSelectButton(_:)), for: .touchUpInside)
    viewModel.image(for: asset, onResult: { image in
      guard cell.assetIndentifier == asset.localIdentifier else { return }
      cell.reuseCell(image: image, index: indexPath.item)
    })
    let selectButtonOffset = imagePickerView!.actionsView.selectButtonOffset(
      forCellAt: indexPath.item,
      contentOffsetX: collectionView.contentOffset.x
    )
    cell.setSelectButtonPosition(selectButtonOffset)
    if let index = viewModel.selectedImageIndices.firstIndex(of: indexPath.item) {
      cell.selectedCount = index + 1
    }
    cell.previewImageView.hero.id = indexPath.item.description
    return cell
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
}

extension ImagePickerVC: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    viewModel.openImagesPreview(startAt: indexPath.item)
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    imagePickerView?.collectionViewDidScroll()
		guard let collectionView = scrollView as? UICollectionView else { return }
		viewModel.attemptToCacheAssets(collectionView)
  }
}
