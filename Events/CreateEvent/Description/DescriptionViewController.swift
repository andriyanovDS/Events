//
//  DescriptionViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift
import Photos.PHAsset

class DescriptionViewController: UIViewControllerWithActivityIndicator, ViewModelBased, ScreenWithResult {
	var onResult: (([DescriptionWithAssets]) -> Void)!
  var viewModel: DescriptionViewModel!
  private let disposeBag = DisposeBag()
  private var descriptionView: DescriptionView?
	private var isDeleteMode: Bool = false
  private var feedbackGenerator: UIImpactFeedbackGenerator?
  
  override func viewDidLoad() {
    super.viewDidLoad()
	
    viewModel.delegate = self
    setupView()
    keyboardAttachWithDebounce$.subscribe(
      onNext: {[weak self] info in
        self?.descriptionView?.keyboardHeightDidChange(info)
       }
     )
     .disposed(by: disposeBag)
  }

  private func setupView() {
    let view = DescriptionView(
      state: .main(
        isSelectedImagesEmpty: viewModel.storage.assets.isEmpty,
        text: viewModel.storage.text
      )
    )
    setupOpenImagePickerButton()
    view.selectedImagesCollectionView.delegate = self
    view.selectedImagesCollectionView.dataSource = self
    view.selectedImagesCollectionView.dragDelegate = self
    view.selectedImagesCollectionView.dropDelegate = self
    view.descriptionsCollectionView.dataSource = self
    view.descriptionsCollectionView.delegate = self
    view.textView.rx.text.orEmpty
      .subscribe(onNext: {[unowned self] text in
        self.descriptionTextDidChange(text)
      })
      .disposed(by: disposeBag)
    
    view.titleTextField.rx.text.orEmpty
      .subscribe(onNext: {[unowned self] text in
        self.descriptionTitleDidChange(text)
      })
      .disposed(by: disposeBag)
    
    view.submitButton.rx.tap
      .subscribe(onNext: {[unowned self] in self.viewModel.openNextScreen() })
      .disposed(by: disposeBag)
    
    let longPressGestureRecognizer = UILongPressGestureRecognizer(
      target: self,
      action: #selector(onDescriptionCollectionViewLongPress)
    )
    longPressGestureRecognizer.minimumPressDuration = 1
    view.descriptionsCollectionView.addGestureRecognizer(longPressGestureRecognizer)
    self.view = view
    self.descriptionView = view
  }
  
  private func descriptionTextDidChange(_ text: String) {
    viewModel.storage.text = text
    guard let view = descriptionView else { return }
    view.submitButton.isEnabled = !text.isEmpty
  }
  
  func descriptionTitleDidChange(_ text: String) {
    viewModel.storage.title = text
    guard let view = descriptionView else { return }
    let cellOption = view.descriptionsCollectionView.cellForItem(at: IndexPath(
      item: viewModel.storage.activeIndex,
      section: 0
    ))
    guard let cell = cellOption as? DescriptionCellView else { return }
    cell.titleLabel.text = title
  }

  private func setupOpenImagePickerButton() {
     let openImagePickerButton = UIButtonScaleOnPress()
     openImagePickerButton.setImage(
       UIImage(named: "AddImage"),
       for: .normal
     )
     openImagePickerButton.imageView?.style { v in
       v.clipsToBounds = true
       v.contentMode = .scaleAspectFit
     }

     navigationItem.rightBarButtonItem = UIBarButtonItem(customView: openImagePickerButton)
     openImagePickerButton.width(35).height(35)
     openImagePickerButton.addTarget(
       viewModel,
       action: #selector(viewModel.openImagePicker),
       for: .touchUpInside
     )
   }
	
	private func setupCancelBarButton() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			title: NSLocalizedString("Cancel", comment: "Create event description view: cancel delete"),
			style: .plain,
			target: self,
			action: #selector(cancelDeleteMode)
		)
	}
	
	@objc private func cancelDeleteMode() {
		if !isDeleteMode { return }
		isDeleteMode = false
		descriptionView?.descriptionsCollectionView.reloadData()
		setupOpenImagePickerButton()
	}

  @objc private func onRemoveImage(_ sender: UIButtonScaleOnPress) {
    guard let asset = sender.uniqueData as? PHAsset else { return }
    viewModel.removeAsset(asset)
  }
  
  func configure(
    selectedImageCell: SelectedImageCell,
    at index: Int
  ) {
    let asset = viewModel.storage.assets[index].asset
    viewModel.image(for: asset, onResult: { image in
      selectedImageCell.setImage(image, asset: asset)
    })
    selectedImageCell.removeButton.addTarget(self, action: #selector(onRemoveImage(_:)), for: .touchUpInside)
  }
  
  func configure(
    descriptionCell: DescriptionCellView,
    at index: Int
  ) {
    let description = viewModel.storage[dynamicMember: index]
    descriptionCell.titleLabel.text = description.title
    descriptionCell.isActive = viewModel.storage.activeIndex == index
    descriptionCell.addButton?.id = description.id
    if !isDeleteMode {
      descriptionCell.isLastCell = index == viewModel.storage.count - 1
      descriptionCell.addButton?.addTarget(self, action: #selector(addDescription), for: .touchUpInside)
    } else if !description.isMain {
      descriptionCell.isDeleteMode = isDeleteMode
      descriptionCell.removeButton?.addTarget(self, action: #selector(removeDescription(_:)), for: .touchUpInside)
    }
  }
  
  private func updateViewState() {
    guard let view = descriptionView else { return }
    let storage = viewModel.storage
    let isMain = storage[dynamicMember: storage.activeIndex].isMain
    view.state = isMain
      ? .main(isSelectedImagesEmpty: storage.assets.isEmpty, text: storage.text)
      : .additional(isSelectedImagesEmpty: storage.assets.isEmpty, title: storage.title ?? "", text: storage.text)
  }
  
  @objc private func addDescription() {
    guard let descriptionView = self.descriptionView else { return }
    viewModel.addDescription()
    let collectionView = descriptionView.descriptionsCollectionView
    let newCellIndexPath = IndexPath(
      item: viewModel.storage.activeIndex,
      section: 0
    )
    collectionView.visibleCells
      .compactMap { $0 as? DescriptionCellView }
      .forEach { v in
        if v.isLastCell == true {
          v.isLastCell = false
        }
        v.isActive = false
    }
    
    collectionView.performBatchUpdates({
      collectionView.insertItems(at: [newCellIndexPath])
    }, completion: {[unowned self] _ in
      self.updateViewState()
      descriptionView.selectedImagesCollectionView.reloadData()
      collectionView.scrollToItem(at: newCellIndexPath, at: .right, animated: true)
    })
  }
  
  private func changeDescription(afterRemoveAt index: Int) {
    guard let collectionView = descriptionView?.descriptionsCollectionView else {
      return
    }
    let cellOption = collectionView.cellForItem(at: IndexPath(
      item: viewModel.storage.activeIndex,
      section: 0
    ))
    guard let cell = cellOption as? DescriptionCellView else { return }
    collectionView.visibleCells
      .compactMap { $0 as? DescriptionCellView }
      .forEach { $0.isActive = cell == $0 }
    updateViewState()
    descriptionView?.selectedImagesCollectionView.reloadData()
    if viewModel.storage.values.count == 1 {
      cancelDeleteMode()
    }
  }
  
  @objc private func removeDescription(_ sender: DescriptionCellButton) {
    guard let descriptionView = self.descriptionView else { return }
    let collectionView = descriptionView.descriptionsCollectionView
    let cellIndexOption = viewModel.storage.values.firstIndex(where: {
      $0.id == sender.id
    })
    guard let index = cellIndexOption else { return }
    let isViewUpdateRequired = index == viewModel.storage.activeIndex
    viewModel.removeDescription(at: index)
    collectionView.performBatchUpdates({
      collectionView.deleteItems(at: [IndexPath(
        item: index,
        section: 0
        )])
    }, completion: {[weak self] _ in
      if isViewUpdateRequired {
        self?.changeDescription(afterRemoveAt: index)
      }
    })
  }
  
  @objc private func onDescriptionCollectionViewLongPress(
    _ recognizer: UILongPressGestureRecognizer
  ) {
    switch recognizer.state {
    case .began:
      feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
      feedbackGenerator?.prepare()
    case .changed:
      if isDeleteMode { return }
      isDeleteMode = true
      feedbackGenerator?.impactOccurred()
      descriptionView?.descriptionsCollectionView.reloadData()
      setupCancelBarButton()
    case .ended:
      feedbackGenerator = nil
    default:
      return
    }
  }
}

extension DescriptionViewController: DescriptionViewModelDelegate {
	func showProgress() {
		showActivityIndicator(for: view)
	}
	
	func hideProgress() {
		removeActivityIndicator()
	}
	
  func performCellsUpdate(removedIndexPaths: [IndexPath], insertedIndexPaths: [IndexPath]) {
    guard let descriptionView = self.descriptionView else { return }
    let collectionView = descriptionView.selectedImagesCollectionView

    if collectionView.visibleCells.count == 0 && insertedIndexPaths.count > 0 {
      updateViewState()
    }

    collectionView.performBatchUpdates({
      if removedIndexPaths.count > 0 {
        collectionView.deleteItems(at: removedIndexPaths)
      }
      if insertedIndexPaths.count > 0 {
        collectionView.insertItems(at: insertedIndexPaths)
      }
    }, completion: {[weak self] _ in
      if collectionView.visibleCells.count == 0 {
        self?.updateViewState()
      }
    })
  }
}

extension DescriptionViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    itemsForBeginning session: UIDragSession,
    at indexPath: IndexPath
  ) -> [UIDragItem] {
    let itemProvider = NSItemProvider(object: String(indexPath.item) as NSString)
    let dragItem = UIDragItem(itemProvider: itemProvider)
    return [dragItem]
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    dropSessionDidUpdate session: UIDropSession,
    withDestinationIndexPath destinationIndexPath: IndexPath?
  ) -> UICollectionViewDropProposal {
    if collectionView.hasActiveDrag {
      return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    return UICollectionViewDropProposal(operation: .forbidden)
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    performDropWith coordinator: UICollectionViewDropCoordinator
  ) {
    guard let item = coordinator.items.first else { return }
    guard let sourceIndexPath = item.sourceIndexPath else { return }
    let destinationIndexPath = coordinator
      .destinationIndexPath
      .getOrElse(result: IndexPath(
        item: viewModel.storage.assets.count - 1,
        section: 0
      ))
    
    collectionView.performBatchUpdates({
      viewModel.moveAsset(at: sourceIndexPath.item, to: destinationIndexPath.item)
      collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
    }, completion: nil)
    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
  }
}

extension DescriptionViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView is DescriptionsCollectionView {
      return viewModel.storage.count
    }
    return viewModel.storage.assets.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView is DescriptionsCollectionView {
      let cellOption = collectionView.dequeueReusableCell(
        withReuseIdentifier: DescriptionCellView.reuseIdentifier,
        for: indexPath
      )
      guard let cell = cellOption as? DescriptionCellView else {
        fatalError("Unexpected description cell on IndexPath \(indexPath.description)")
      }
      configure(descriptionCell: cell, at: indexPath.item)
      return cell
    }
    let cellOption = collectionView.dequeueReusableCell(
      withReuseIdentifier: SelectedImageCell.reuseIdentifier,
      for: indexPath
    )
    guard let cell = cellOption as? SelectedImageCell else {
      fatalError("Unexpected assets cell on IndexPath \(indexPath.description)")
    }
    configure(selectedImageCell: cell, at: indexPath.item)
    return cell
  }
}

extension DescriptionViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard collectionView is DescriptionsCollectionView else { return }
    
    if indexPath.item == viewModel.storage.activeIndex { return }
    guard let descriptionView = self.descriptionView else { return }

    let collectionView = descriptionView.descriptionsCollectionView
    guard let cell = collectionView.cellForItem(at: indexPath) as? DescriptionCellView else { return }
    viewModel.descriptionDidSelected(at: indexPath.item)
    cell.selectAnimation.startAnimation()
    updateViewState()
    collectionView
      .visibleCells
      .compactMap { $0 as? DescriptionCellView }
      .filter { $0.isActive }
      .forEach { $0.isActive = false }
    cell.isActive = true
    descriptionView.selectedImagesCollectionView.reloadData()
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let collectionView = scrollView as? UICollectionView else { return }
    if collectionView is DescriptionsCollectionView { return }
    viewModel.attemptToCacheAssets(collectionView)
  }
}
