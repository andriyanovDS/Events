//
//  CalendarViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 06/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift

class CalendarViewController: UIViewController, ScreenWithResult {
  var onResult: ((SelectedDates?) -> Void)!
  private var calendarCloseByGestureRecognizer: CalendarCloseByGestureRecognizer?
  private let dataSource: CalendarDataSource
  private let viewModel: CalendarViewModel
  private var contentView: CalendarContentView?
  private let screenWidth = UIScreen.main.bounds.width
  private let disposeBag = DisposeBag()
  
  init(dataSource: CalendarDataSource, viewModel: CalendarViewModel) {
    self.dataSource = dataSource
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  override func viewDidLayoutSubviews() {
    let index = dataSource.activeMonthIndex
    if index != 0 {
      contentView?.monthsCollectionView.scrollToItem(
        at: IndexPath(item: 0, section: index),
        at: .top,
        animated: false
      )
    }
  }

  private func setupView() {
    let view = CalendarContentView()
    view.monthsCollectionView.dataSource = dataSource
    view.monthsCollectionView.delegate = self
    
    view.headerView.closeButton.rx.tap
      .subscribe(onNext: {[unowned self] in
        self.onClose()
      })
      .disposed(by: disposeBag)
    view.footerView.clearButton.rx.tap
      .subscribe(onNext: {[unowned self] in
        self.clearDates()
      })
      .disposed(by: disposeBag)
    view.footerView.saveButton.rx.tap
      .subscribe(onNext: {[unowned self] in
        self.onResult(self.dataSource.selectedDates)
        self.viewModel.onClose()
      })
      .disposed(by: disposeBag)
    
    let tapOutsideGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onClose))
    tapOutsideGestureRecognizer.cancelsTouchesInView = false
    view.backgroundView.addGestureRecognizer(tapOutsideGestureRecognizer)
    
    calendarCloseByGestureRecognizer = CalendarCloseByGestureRecognizer(
      parentView: view,
      animatedView: view.contentView,
      gestureBounds: CGRect(x: 0, y: 0, width: 0, height: 75),
      onClose: {[unowned self] in self.onClose() }
    )
    view.footerView.setIsClearButtonEnabled(dataSource.selectedDateFrom != nil)
    self.view = view
    self.contentView = view
  }
  
  @objc private func onClose() {
    onResult(nil)
    viewModel.onClose()
  }
  
  private func clearDates() {
    dataSource.clearDates()
    guard let view = contentView else { return }
    view.headerView.setSelectedDatesTitle(
      selectedDatesToTitle()
    )
    view.footerView.setIsClearButtonEnabled(false)
    view.monthsCollectionView.reloadData()
  }
  
  private func datesToTitleFn(dateFormatter: DateFormatter) -> (Date) -> (Date) -> String {
    return { to in {
      dateFormatter.string(from: $0) + " - " + dateFormatter.string(from: to)
    }}
  }
  
  private func selectedDatesToTitle() -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM"
    dateFormatter.locale = Locale(identifier: "ru_RU")
    guard let from = dataSource.selectedDateFrom else { return nil }
    guard let dateTo = dataSource.selectedDateTo else {
      return dateFormatter.string(from: from)
    }
    return [from, dateTo]
      .map { dateFormatter.string(from: $0) }
      .joined(separator: " - ")
  }
}

extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int
  ) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 40)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let dayOptional = dataSource.months[indexPath.section].days[indexPath.item]
    guard let day = dayOptional, !day.isInPast else { return }
    dataSource.selectDate(day.date)
    contentView?.headerView.setSelectedDatesTitle(selectedDatesToTitle())
    contentView?.footerView.setIsClearButtonEnabled(true)
    collectionView.reloadData()
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let collectionWidth = collectionView.bounds.width - 50
    let width = Int(collectionWidth / 7)
    if indexPath.item % 7 == 0 {
      return CGSize(width: width + 1, height: width)
    }
    return CGSize(width: width, height: width)
  }
}
