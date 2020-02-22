//
//  CreateEventViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import RxFlow
import RxCocoa
import Photos
import Promises

class CreateEventViewModel: Stepper {
  let steps = PublishRelay<Step>()
  weak var delegate: CreateEventViewModelDelegate?
  private let disposeBag = DisposeBag()
  private let imageCacheManager: ImageCacheManager

  var geocode: Geocode?
  var dates: [Date]
  var duration: EventDurationRange?
  var category: CategoryId?
  var selectedAssets: [PHAsset] = []

  var durations: [EventDurationRange] = [
    EventDurationRange(min: nil, max: 1)!,
    EventDurationRange(min: nil, max: 2)!,
    EventDurationRange(min: 3, max: 5)!,
    EventDurationRange(min: 5, max: 8)!,
    EventDurationRange(min: 8, max: nil)!
  ]

  init() {
    dates = generateInitialDates()
    let scale = UIScreen.main.scale
    imageCacheManager = ImageCacheManager(
      targetSize: CGSize(
        width: SELECTED_IMAGE_SIZE.width * scale,
        height: SELECTED_IMAGE_SIZE.height * scale
      ),
      imageRequestOptions: nil
    )
    self.duration = self.durations[0]
    geocodeObserver
      .take(1)
      .subscribe(onNext: {[weak self] geocode in
        self?.geocode = geocode
        self?.delegate?.onLocationNameDidChange(geocode.fullLocationName())
      })
      .disposed(by: disposeBag)
  }

  func closeScreen() {
    steps.accept(EventStep.createEventDidComplete)
  }

  func openLocationSearchBar() {
    steps.accept(EventStep.locationSearch(onResult: { geocode in
      self.geocode = geocode
      self.delegate?.onLocationNameDidChange(geocode.fullLocationName())
    }))
  }

  func openCalendar() {
    steps.accept(EventStep.calendar(
      withSelectedDates: SelectedDates(from: nil, to: nil),
      onComplete: { selectedDates in
        selectedDates
          .foldL(
            none: {},
            some: { dates in
              let dateRangeFnOption = dates.to
                .map { dateRange(end: $0) }
                .orElse { [$0] }

              self.dates = dates.from
                .ap(dateRangeFnOption)
                .getOrElseL(generateInitialDates)

              if let foramttedDate = dates.localizedLabel {
                let daysDiff = daysCount(selectedDates: dates)
                self.delegate?.onDatesDidSelected(formattedDate: foramttedDate, daysCount: daysDiff)
              }
            }
          )
      }
    ))
  }

  func onSelect(date: Date) {
    let
      hour = Calendar.current.component(.hour, from: date),
      minutes = Calendar.current.component(.minute, from: date)

    dates = dates.map({ v in
      let changedDate = Calendar.current.date(bySettingHour: hour, minute: minutes, second: 0, of: v)
      return changedDate.getOrElse(result: v)
    })
  }

  func onSelect(duration: EventDurationRange) {
    self.duration = duration
  }

  func onSelect(category id: CategoryId) {
    category = id
  }

  func openHintPopup(popup: HintPopup) {
    steps.accept(EventStep.hintPopup(popup: popup))
  }

  func openImagePicker() {
    steps.accept(EventStep.imagePicker(selectedAssets: selectedAssets, onComplete: { assets in
      self.update(assets: assets)
    }))
  }

 func remove(asset: PHAsset) {
    guard let index = selectedAssets.firstIndex(of: asset) else { return }
    selectedAssets.remove(at: index)
    delegate?.performCellsUpdate(
      removedIndexPaths: [IndexPath(item: index, section: 0)],
      insertedIndexPaths: []
    )
  }

  private func update(assets: [PHAsset]) {
    let newAssetsSet = Set(assets.map { $0.localIdentifier })
    let currentAssetsSet = Set(selectedAssets.map { $0.localIdentifier })
    let removedIndices = selectedAssets
      .enumerated()
      .filter {_, asset in !newAssetsSet.contains(asset.localIdentifier) }
      .map { index, _ in index }
    let newAssets: [PHAsset] = assets.filter { !currentAssetsSet.contains($0.localIdentifier) }
    removedIndices
      .enumerated()
      .map { $1 - $0 }
      .forEach { selectedAssets.remove(at: $0) }
    selectedAssets.insert(contentsOf: newAssets, at: selectedAssets.count)

    delegate?.performCellsUpdate(
      removedIndexPaths: removedIndices.map { IndexPath(item: $0, section: 0) },
      insertedIndexPaths: newAssets
        .enumerated()
        .map { index, _ in
          IndexPath(item: selectedAssets.count - newAssets.count + index, section: 0)
        }
      )
  }
}

extension CreateEventViewModel {
  func asset(at index: Int) -> PHAsset {
    selectedAssets[index]
  }

  func image(for asset: PHAsset, onResult: @escaping (UIImage) -> Void) {
    return imageCacheManager.getImage(for: asset, onResult: onResult)
  }

  func attemptToCacheAssets(_ collectionView: UICollectionView) {
    imageCacheManager.attemptToCacheAssets(collectionView, assetGetter: { index in
      selectedAssets[index]
    })
  }
}

private func generateInitialDates() -> [Date] {
  let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .init())!
  return [Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: tomorrow)!]
}

private func dateRange(end: Date) -> (Date) -> [Date] {
  return { start in
    var dates: [Date] = []
    var date = start

    while date <= end {
      dates.append(date)
      date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
    }
    return dates
  }
}

private func daysCount(selectedDates: SelectedDates) -> Int {
  guard let dateFrom = selectedDates.from else {
    return 0
  }
  if let dateTo = selectedDates.to {
    return Calendar.current.compare(dateFrom, to: dateTo, toGranularity: .day).rawValue
  }
  return 1
}

protocol CreateEventViewModelDelegate: class, UIViewControllerWithActivityIndicator {
  func performCellsUpdate(removedIndexPaths: [IndexPath], insertedIndexPaths: [IndexPath])
  func onLocationNameDidChange(_: String)
  func onDatesDidSelected(formattedDate: String, daysCount: Int)
}

struct FailedToLoadBackgroundImage: Error {}
