//
//  ImagePickerVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class ImagePickerVC: UIViewController {
  weak var viewModel: ImagePickerViewModel!
  var imagePickerView: ImagePickerView?

  init(viewModel: ImagePickerViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    viewModel.delegate = self
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.imagePickerView?.animateShowContent()
    }
    viewModel.targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
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

  @objc private func onImageDidSelected(_ button: SelectImageButton) {
    let index = button.tag
    viewModel.onSelectImage(at: index)

    let indexPath = IndexPath(item: index, section: 0)
    guard let cell = imagePickerView?.actionsView.collectionView.cellForItem(at: indexPath) as? ImagePreviewCell else {
      return
    }
    cell.selectButton.setCount(viewModel.selectedImageIndices.count)
    imagePickerView?.onImageDidSelected(at: index, selectedImageIndices: viewModel.selectedImageIndices)
  }
}

extension ImagePickerVC: ImagePickerViewModelDelegate {
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
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      return
    }
    viewModel.closeImagePicker(with: [image])
  }

  func updateImagePreviews(selectedImageIndices: [Int]) {
    imagePickerView?.updateImagePreviews(selectedImageIndices: selectedImageIndices)
  }

  func prepareImagesUpdate() {
    guard let collectionView = imagePickerView?.actionsView.collectionView else {
      return
    }
    collectionView.numberOfItems(inSection: 0)
  }

  func insertImage(at index: Int) {
    guard let collectionView = imagePickerView?.actionsView.collectionView else {
      return
    }
    collectionView.performBatchUpdates({
      let indexPath = IndexPath(item: index, section: 0)
      collectionView.insertItems(at: [indexPath])
    })
  }
}

extension ImagePickerVC: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.images.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "ImagePreviewCell",
      for: indexPath
      ) as? ImagePreviewCell ?? ImagePreviewCell()
    cell.selectButton.tag = indexPath.item
    cell.selectButton.addTarget(self, action: #selector(onImageDidSelected(_:)), for: .touchUpInside)
    let image = viewModel.images[indexPath.item]
    cell.reuseCell(image: image)
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
  }
}
