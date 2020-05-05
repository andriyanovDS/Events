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
  private var dataSource: DescriptionDataSource!
  private var descriptionDelegate: DescriptionCollectionViewDelegate!
  
  init() {
    super.init(nibName: nil, bundle: nil)
    dataSource = DescriptionDataSource(
      assetCellConfigurator: {[unowned self] (asset, cell, indexPath) in
      self.configure(assetCell: cell, with: asset, at: indexPath)
      },
      descriptionCellConfigurator: {[unowned self] (description, cell, meta) in
        self.configure(
          descriptionCell: cell,
          with: description,
          isActive: meta.isActive,
          isLast: meta.isLast
        )
      }
    )
    descriptionDelegate = DescriptionCollectionViewDelegate(dataSource: dataSource) {[unowned self] in
      self.updateViewState()
      self.descriptionView?.selectedImagesCollectionView.reloadData()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
	
    viewModel.delegate = self
    setupView()
    keyboardAttach$.subscribe(
      onNext: {[weak self] info in
        self?.descriptionView?.keyboardHeightDidChange(info)
       }
     )
     .disposed(by: disposeBag)
  }

  private func setupView() {
    let description = dataSource.activeDescription
    let view = DescriptionView(
      state: .main(
        isSelectedImagesEmpty: description.assets.isEmpty,
        text: description.text
      )
    )
    setupOpenImagePickerButton()
    view.selectedImagesCollectionView.delegate = self
    view.descriptionsCollectionView.delegate = descriptionDelegate
    view.selectedImagesCollectionView.dataSource = dataSource.assetsDataSource
    view.descriptionsCollectionView.dataSource = dataSource.descriptionDataSource
    view.selectedImagesCollectionView.dragDelegate = self
    view.selectedImagesCollectionView.dropDelegate = self
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
      .subscribe(onNext: {[unowned self] in self.onSubmit() })
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
  
  private func configure(
    descriptionCell cell: DescriptionCellView,
    with description: DescriptionWithAssets,
    isActive: Bool,
    isLast: Bool
  ) {
    cell.titleLabel.text = description.title
    cell.isActive = isActive
    if !isDeleteMode {
      cell.state = isLast ? .add : .normal
      cell.closure = {[unowned self] in
        self.addDescription()
      }
    } else if !description.isMain {
      cell.state = self.isDeleteMode ? .delete : .normal
      let id = description.id
      cell.closure = {[unowned self] in
        self.removeDescription(with: id)
      }
    }
  }
  
  private func onSubmit() {
    onResult(dataSource.descriptions)
    viewModel.openNextScreen()
  }
  
  private func configure(
    assetCell cell: SelectedImageCell,
    with asset: DescriptionWithAssets.Asset,
    at indexPath: IndexPath
  ) {
    let id = asset.asset.localIdentifier
    cell.id = id
    viewModel.image(for: asset.asset, onResult: {[weak cell] image in
      guard let cell = cell, cell.id == id else { return }
      cell.setImage(image, asset: asset.asset)
    })
    cell.removeButton.addTarget(self, action: #selector(onRemoveImage(_:)), for: .touchUpInside)
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
      self,
      action: #selector(handleImagePickerButtonPress),
      for: .touchUpInside
    )
  }
  
  @objc private func handleImagePickerButtonPress() {
    viewModel.openImagePicker(
      withSelectedAssets: dataSource.assets,
      completion: {[unowned self] assets in
        let (removed, inserted) = self.dataSource.updateAssets(assets)
        self.performCellsUpdate(removedIndexPaths: removed, insertedIndexPaths: inserted)
      }
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

  private func updateViewState() {
    guard let view = descriptionView else { return }
    let description = dataSource.activeDescription
    let isAssetsEmpty = description.assets.isEmpty
    view.state = description.isMain
      ? .main(isSelectedImagesEmpty: isAssetsEmpty, text: description.text)
      : .additional(
          isSelectedImagesEmpty: isAssetsEmpty,
          title: description.title ?? "",
          text: description.text
        )
  }
  
  private func performCellsUpdate(removedIndexPaths: [IndexPath], insertedIndexPaths: [IndexPath]) {
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

extension DescriptionViewController {
  @objc private func onRemoveImage(_ sender: UIButtonScaleOnPress) {
    guard let asset = sender.uniqueData as? PHAsset else { return }
    let assets = dataSource.assetsDataSource.models
    guard let index = assets.firstIndex(where: { $0.asset == asset }) else {
      return
    }
    dataSource.removeAsset(at: index)
    performCellsUpdate(
      removedIndexPaths: [IndexPath(item: index, section: 0)],
      insertedIndexPaths: []
    )
  }
}

extension DescriptionViewController {
  private func addDescription() {
    guard let descriptionView = self.descriptionView else { return }
    dataSource.addDescription()
    let collectionView = descriptionView.descriptionsCollectionView
    let newCellIndexPath = IndexPath(
      item: dataSource.activeDescriptionIndex,
      section: 0
    )
    collectionView.visibleCells
      .compactMap { $0 as? DescriptionCellView }
      .forEach { v in
        v.state = .normal
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
  
  private func updateActiveDescription() {
    guard let collectionView = descriptionView?.descriptionsCollectionView else {
      return
    }
    let cellOption = collectionView.cellForItem(at: IndexPath(
      item: dataSource.activeDescriptionIndex,
      section: 0
    ))
    guard let cell = cellOption as? DescriptionCellView else { return }
    cell.isActive = true
    updateViewState()
    descriptionView?.selectedImagesCollectionView.reloadData()
  }
  
  private func removeDescription(with id: String) {
    guard let descriptionView = self.descriptionView else { return }
    let collectionView = descriptionView.descriptionsCollectionView
    let cellIndexOption = dataSource.descriptions.firstIndex(where: {
      $0.id == id
    })
    guard let index = cellIndexOption else { return }
    let isViewUpdateRequired = index == dataSource.activeDescriptionIndex
    dataSource.removeDescription(at: index)
    collectionView.performBatchUpdates({
      collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }, completion: {[weak self] _ in
      guard let self = self else { return }
      if isViewUpdateRequired {
        self.updateActiveDescription()
      }
      if self.dataSource.descriptions.count == 1 {
        self.cancelDeleteMode()
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
  
  private func descriptionTextDidChange(_ text: String) {
    dataSource.updateActiveDescriptionText(text)
    guard let view = descriptionView else { return }
    view.submitButton.isEnabled = !text.isEmpty
  }
  
  func descriptionTitleDidChange(_ text: String) {
    dataSource.updateActiveDescriptionTitle(text)
    guard let view = descriptionView else { return }
    let cellOption = view.descriptionsCollectionView.cellForItem(at: IndexPath(
      item: dataSource.activeDescriptionIndex,
      section: 0
    ))
    guard let cell = cellOption as? DescriptionCellView else { return }
    cell.titleLabel.text = text
  }
}

extension DescriptionViewController: DescriptionViewModelDelegate {
	func showProgress() {
		showActivityIndicator(for: view)
	}
	
	func hideProgress() {
		removeActivityIndicator()
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
        item: dataSource.assets.count - 1,
        section: 0
      ))
    
    collectionView.performBatchUpdates({
      dataSource.moveAsset(from: sourceIndexPath.item, to: destinationIndexPath.item)
      collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
    }, completion: nil)
    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
  }
}

extension DescriptionViewController: UICollectionViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let collectionView = scrollView as? UICollectionView else { return }
    if collectionView is DescriptionsCollectionView { return }
    viewModel.attemptToCacheAssets(collectionView) {[unowned self] index in
      self.dataSource.assetsDataSource.model(at: index).asset
    }
  }
}
