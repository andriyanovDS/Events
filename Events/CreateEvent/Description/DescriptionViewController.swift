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
  var viewModel: DescriptionViewModel! {
    didSet {
      viewModel.delegate = self
    }
  }
  private let disposeBag = DisposeBag()
  private var descriptionView: DescriptionView?
  private var activeDescriptionIndex: Int = 0
	private var isDeleteMode: Bool = false
  private var feedbackGenerator: UIImpactFeedbackGenerator?

  override func viewDidLoad() {
    super.viewDidLoad()
	
    setupView()
    keyboardAttachWithDebounce$.subscribe(
      onNext: {[weak self] info in
        self?.descriptionView?.keyboardHeightDidChange(info)
       }
     )
     .disposed(by: disposeBag)
  }

  private func setupView() {
    let descriptionView = DescriptionView()
    descriptionView.delegate = self
    setupOpenImagePickerButton()
    view = descriptionView
    self.descriptionView = descriptionView
    let longPressGestureGecognizer = UILongPressGestureRecognizer(
      target: self,
      action: #selector(onDescriptionCollectionViewLongPress)
    )
    longPressGestureGecognizer.minimumPressDuration = 1
    descriptionView.descriptionsCollectionView.addGestureRecognizer(longPressGestureGecognizer)
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
     openImagePickerButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
   }
	
	private func setupCancelBarButton() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			title: NSLocalizedString("Cancel", comment: "Create event description view: cancel delete"),
			style: .plain,
			target: self,
			action: #selector(cancelDeleteMode)
		)
	}

  @objc private func openImagePicker() {
    viewModel.openImagePicker(activeDescription: activeDescriptionIndex)
  }
	
	@objc private func cancelDeleteMode() {
		if !isDeleteMode { return }
		isDeleteMode = false
		descriptionView?.descriptionsCollectionView.reloadData()
		setupOpenImagePickerButton()
	}

  @objc private func onRemoveImage(_ sender: UIButtonScaleOnPress) {
    guard let asset = sender.uniqueData as? PHAsset else { return }
    viewModel.remove(asset: asset, forDescriptionAtIndex: activeDescriptionIndex)
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
      descriptionView.showSelectedImagesCollectionView()
    }

    collectionView.performBatchUpdates({
      if removedIndexPaths.count > 0 {
        collectionView.deleteItems(at: removedIndexPaths)
      }
      if insertedIndexPaths.count > 0 {
        collectionView.insertItems(at: insertedIndexPaths)
      }
    }, completion: { _ in
      if collectionView.visibleCells.count == 0 {
        descriptionView.hideSelectedImagesCollectionView()
      }
    })
  }
}

extension DescriptionViewController: DescriptionViewDelegate {
  func openNextScreen() {
    viewModel.openNextScreen()
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView is DescriptionsCollectionView {
      return viewModel.descriptions.count
    }
    return viewModel.descriptions[activeDescriptionIndex].assets.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView is DescriptionsCollectionView {
      let cellIdentidier = String(describing: DescriptionCellView.self)
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: cellIdentidier,
        for: indexPath
        ) as? DescriptionCellView else {
        fatalError("Unexpected description cell on IndexPath \(indexPath.description)")
      }
      let description = viewModel.descriptions[indexPath.item]
      cell.eventDescription = description
			cell.isActive = activeDescriptionIndex == indexPath.item

			if !isDeleteMode {
				cell.isLastCell = indexPath.item == viewModel.descriptions.count - 1
				cell.addButton?.addTarget(self, action: #selector(addDescription), for: .touchUpInside)
      } else if !description.isMain {
        cell.isDeleteMode = isDeleteMode
        cell.removeButton?.addTarget(self, action: #selector(removeDescription(_:)), for: .touchUpInside)
      }
      cell.setupCell()
      return cell
    }

    let cellIdentidier = String(describing: SelectedImageCell.self)
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: cellIdentidier,
      for: indexPath
      ) as? SelectedImageCell else {
      fatalError("Unexpected assets cell on IndexPath \(indexPath.description)")
    }
    let asset = viewModel.asset(at: indexPath.item, forDescriptionAtIndex: activeDescriptionIndex)
    viewModel.image(for: asset, onResult: { image in
      cell.setImage(image, asset: asset)
    })
    cell.removeButton.addTarget(self, action: #selector(onRemoveImage(_:)), for: .touchUpInside)
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard collectionView is DescriptionsCollectionView else { return }
    if indexPath.item == activeDescriptionIndex { return }
    guard let descriptionView = self.descriptionView else { return }

    let collectionView = descriptionView.descriptionsCollectionView
    guard let cell = collectionView.cellForItem(at: indexPath) as? DescriptionCellView else { return }
    activeDescriptionIndex = indexPath.item
    cell.selectAnimation.startAnimation()
    descriptionView.onChange(description: cell.eventDescription!)
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
    viewModel.attemptToCacheAssets(collectionView, forDescriptionAtIndex: activeDescriptionIndex)
  }

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
				item: viewModel.descriptions[activeDescriptionIndex].assets.count - 1,
				section: 0
			))

    collectionView.performBatchUpdates({
			let asset = viewModel.descriptions[activeDescriptionIndex].assets[sourceIndexPath.item]
      viewModel.descriptions[activeDescriptionIndex].assets.remove(at: sourceIndexPath.item)
      viewModel.descriptions[activeDescriptionIndex].assets.insert(asset, at: destinationIndexPath.item)
      collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
    }, completion: nil)
    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
  }

  func description(titleDidChange title: String) {
    viewModel.descriptions[activeDescriptionIndex].title = title
		guard let view = descriptionView else { return }
		let cellOption = view.descriptionsCollectionView.cellForItem(at: IndexPath(
			item: activeDescriptionIndex,
			section: 0
		))
		guard let cell = cellOption as? DescriptionCellView else { return }
		cell.eventDescription = viewModel.descriptions[activeDescriptionIndex]
		cell.change(labelText: title)
  }

  func description(textDidChange text: String) {
    viewModel.descriptions[activeDescriptionIndex].text = text
		guard let view = descriptionView else { return }
		let cellOption = view.descriptionsCollectionView.cellForItem(at: IndexPath(
			item: activeDescriptionIndex,
			section: 0
		))
		guard let cell = cellOption as? DescriptionCellView else { return }
		cell.eventDescription = viewModel.descriptions[activeDescriptionIndex]
  }

  @objc private func addDescription() {
    guard let descriptionView = self.descriptionView else { return }
    viewModel.addDescription()
    let collectionView = descriptionView.descriptionsCollectionView
    let newCellIndexPath = IndexPath(
      item: viewModel.descriptions.count - 1,
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

    activeDescriptionIndex = newCellIndexPath.item

    collectionView.performBatchUpdates({
      collectionView.insertItems(at: [newCellIndexPath])
    }, completion: {[unowned self] _ in
      descriptionView.onChange(description: self.viewModel.descriptions[newCellIndexPath.item])
      descriptionView.selectedImagesCollectionView.reloadData()
      collectionView.scrollToItem(at: newCellIndexPath, at: .right, animated: true)
    })
  }

  private func changeDescription(afterRemoveAt index: Int) {
    guard activeDescriptionIndex == index else {
      activeDescriptionIndex -= 1
      return
    }
    activeDescriptionIndex = index - 1
    guard let collectionView = descriptionView?.descriptionsCollectionView else {
      return
    }
    let cellOption = collectionView.cellForItem(at: IndexPath(
      item: activeDescriptionIndex,
      section: 0
    ))
    guard let cell = cellOption as? DescriptionCellView else { return }
    collectionView.visibleCells
      .compactMap { $0 as? DescriptionCellView }
      .forEach { $0.isActive = cell == $0 }
    let description = viewModel.descriptions[activeDescriptionIndex]
    descriptionView?.onChange(description: description)
    descriptionView?.selectedImagesCollectionView.reloadData()
    if viewModel.descriptions.count == 1 {
      cancelDeleteMode()
    }
  }

  @objc private func removeDescription(_ sender: DescriptionCellButton) {
    guard let descriptionView = self.descriptionView else { return }
    let collectionView = descriptionView.descriptionsCollectionView
    let cellIndexOption = viewModel.descriptions.firstIndex(where: { v in
      v == sender.dataSource?.eventDescription
    })
    guard let index = cellIndexOption else { return }
    viewModel.remove(descriptionAtIndex: index)
    collectionView.performBatchUpdates({
      collectionView.deleteItems(at: [IndexPath(
        item: index,
        section: 0
        )])
    }, completion: {[weak self] _ in
      self?.changeDescription(afterRemoveAt: index)
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
