//
//  CreateEventVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import RxSwift
import Photos.PHAsset
import SwiftIconFont

@objc protocol CreateEventViewDelegate: class {
  func openNextScreen()
}

protocol CreateEventView: UIView {
	associatedtype Delegate = CreateEventViewDelegate
  var delegate: Delegate { get set }
}

protocol ViewWithKeyboard {
  func keyboardHeightDidChange(_: KeyboardAttachInfo?)
}

class CreateEventViewController: UIViewControllerWithActivityIndicator, ViewModelBased {
  var viewModel: CreateEventViewModel!
  private var foregroundView: UIView?
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    setupView()
    showActivityIndicator(for: nil)

    keyboardAttach$
    .subscribe(
      onNext: {[weak self] info in
        if let view = self?.foregroundView as? ViewWithKeyboard {
          view.keyboardHeightDidChange(info)
        }
      }
    )
    .disposed(by: disposeBag)
  }

  private func setupView() {
    viewModel.delegate = self
    view.backgroundColor = .white

    let view = setupLocationView()
    push(view: view)
  }

  private func setupLocationView() -> UIView {
    let locationView = LocationView()
    locationView.delegate = self
    if let locationName = viewModel.geocode?.fullLocationName() {
      locationView.setLocationName(locationName)
    }
    return locationView
  }
  
  private func setupDateView() -> UIView {
    let dateView = DateView(date: viewModel.dates[0])
		if let duration = viewModel.duration {
			dateView.setDurationLabelText(duration.localizedLabel)
		}
    dateView.delegate = self
    return dateView
  }

  func setupCategoriesView() -> UIView {
    let categoriesView = CategoriesView()
    categoriesView.delegate = self
    return categoriesView
  }

  func setupDescriptionView() -> UIView {
    let descriptionView = DescriptionView()
    descriptionView.delegate = self
    push(view: descriptionView)
    setupOpenImagePickerButton()

//    let popup = HintPopup(
//      title: NSLocalizedString("Format you text", comment: "Format text hint: title"),
//      description: NSLocalizedString(
//        "Format you text using special symbols to make it more detailed",
//        comment: "Format text hint: description"
//      ),
//      link: NSLocalizedString("Press to get more info", comment: "Format text hint: open hint button label"),
//      image: UIImage(named: "textFormatting")!
//    )
//    viewModel.openHintPopup(popup: popup)
    return descriptionView
  }

  private func attach(view: UIView) {
    self.view.sv(view)
    view.fillHorizontally()
    view.Top == self.view.safeAreaLayoutGuide.Top
    view.Bottom == self.view.safeAreaLayoutGuide.Bottom
  }

  private func pop(view: UIView) {
    attach(view: view)
    guard let currentView = foregroundView else { return }
    self.view.bringSubviewToFront(currentView)
    view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 1,
      options: .curveEaseIn,
      animations: {
        currentView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        view.transform = .identity
      },
      completion: { _ in
        currentView.removeFromSuperview()
        self.foregroundView = view
      }
    )
  }

  private func push(view: UIView) {
    attach(view: view)
    guard let currentView = foregroundView else {
      foregroundView = view
      return
    }
    view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 1,
      options: .curveEaseIn,
      animations: {
        view.transform = .identity
        currentView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      },
      completion: { _ in
        currentView.removeFromSuperview()
        self.foregroundView = view
      }
    )
  }

  @objc func openPreviousScreen() {
    guard let currentView = foregroundView else { return }
    var prevView: UIView?
    switch currentView {
    case is DescriptionView:
      prevView = setupCategoriesView()
      navigationItem.rightBarButtonItem = nil
    case is CategoriesView:
      prevView = setupDateView()
    case is DateView:
      prevView = setupLocationView()
    default:
      break
    }
    guard let view = prevView else {
      viewModel.closeScreen()
      return
    }
    pop(view: view)
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

  private func isDescriptionValid(_ textView: UITextView) -> Bool {
    return textView.text.count > 0
  }

  @objc private func openImagePicker() {
    viewModel.openImagePicker()
  }
  
  private func setupNavigationBar() {
    navigationController?.navigationBar.barTintColor = UIColor.white
    let backButtonImage = UIImage(
      from: .ionicon,
      code: "ios-arrow-back",
      textColor: .black,
      backgroundColor: .clear,
      size: CGSize(width: 40, height: 40)
    )
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: backButtonImage,
      style: .plain,
      target: self,
      action: #selector(openPreviousScreen)
    )
    navigationController?.isNavigationBarHidden = false
  }

  @objc private func onRemoveImage(_ sender: UIButtonScaleOnPress) {
    guard let asset = sender.uniqueData as? PHAsset else { return }
    viewModel.remove(asset: asset)
  }
}

extension CreateEventViewController: CreateEventViewDelegate {
	func openNextScreen() {
    guard let currentView = foregroundView else { return }
    var nextView: UIView?
    switch currentView {
    case is LocationView:
      nextView = setupDateView()
    case is DateView:
      nextView = setupCategoriesView()
    case let categoryView as CategoriesView:
      if let category = categoryView.selectedCategory {
        viewModel.onSelect(category: category)
      }
      nextView = setupDescriptionView()
    default:
      return
    }
    guard let view = nextView else { return }
    push(view: view)
	}
}

extension CreateEventViewController: LocationViewDelegate {
	func openChangeLocationModal() {
		viewModel.openLocationSearchBar()
	}
}

extension CreateEventViewController: DateViewDelegate {
  func onSelect(duration: EventDurationRange) {
    viewModel.onSelect(duration: duration)
  }

  func onSelect(date: Date) {
    viewModel.onSelect(date: date)
  }

  func onOpenCalendar() {
    viewModel.openCalendar()
  }

  private func pickerRowValueToDurationRange(_ row: Int) -> EventDurationRange? {
    return viewModel.durations[row]
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    guard let view = foregroundView as? DateView else { return }
    onSelect(duration: viewModel.durations[row])
    view.setDurationLabelText(viewModel.durations[row].localizedLabel)
    view.endEditing(true)
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return viewModel.durations[row].localizedLabel
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return viewModel.durations.count
  }
}

extension CreateEventViewController: DescriptionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.selectedAssets.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cellIdentidier = String(describing: SelectedImageCell.self)
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: cellIdentidier,
      for: indexPath
      ) as? SelectedImageCell else {
      fatalError("Unexpected cell on IndexPath \(indexPath.description)")
    }
    let asset = viewModel.asset(at: indexPath.item)
    viewModel.image(for: asset, onResult: { image in
      cell.setImage(image, asset: asset)
    })
    cell.removeButton.addTarget(self, action: #selector(onRemoveImage(_:)), for: .touchUpInside)
    return cell
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let collectionView = scrollView as? UICollectionView else { return }
    viewModel.attemptToCacheAssets(collectionView)
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
			.getOrElse(result: IndexPath(item: viewModel.selectedAssets.count - 1, section: 0))
		
		collectionView.performBatchUpdates({
			let asset = viewModel.asset(at: sourceIndexPath.item)
			viewModel.selectedAssets.remove(at: sourceIndexPath.item)
			viewModel.selectedAssets.insert(asset, at: destinationIndexPath.item)
			
			collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
		}, completion: nil)
		coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
	}
}

extension CreateEventViewController: CreateEventViewModelDelegate {
  func onLocationNameDidChange(_ name: String) {
    guard let locationView = foregroundView as? LocationView else { return }
    locationView.setLocationName(name)
  }

  func onDatesDidSelected(formattedDate: String, daysCount: Int) {
    guard let dateView = foregroundView as? DateView else { return }
    dateView.setFormattedDate(formattedDate, daysCount: daysCount)
  }

  func performCellsUpdate(removedIndexPaths: [IndexPath], insertedIndexPaths: [IndexPath]) {
    guard let collectionView = (foregroundView as? DescriptionView)?.collectionView else {
      return
    }

    if collectionView.visibleCells.count == 0 && insertedIndexPaths.count > 0 {
      guard let descriptionView = foregroundView as? DescriptionView else { return }
      descriptionView.showCollectionView()
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
        guard let descriptionView = self?.foregroundView as? DescriptionView else { return }
        descriptionView.hideCollectionView()
      }
    })
  }
}
