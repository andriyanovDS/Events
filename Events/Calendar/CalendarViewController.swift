//
//  CalendarViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 06/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, UIGestureRecognizerDelegate, ViewModelBased, ScreenWithResult {
  var viewContent: CalendarContentView?
  weak var viewModel: CalendarViewModel! {
    didSet {
      viewModel?.delegate = self
    }
  }
  var onResult: ((SelectedDates?) -> Void)!
  var calendarCloseByGestureRecognizer: CalendarCloseByGestureRecognizer?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
  }

  override func viewDidLayoutSubviews() {
    onSelectedDatesDidChange(viewModel.selectedDates)
    viewModel?.selectedDates.from
      .map { v in
        let currentMonth = Calendar.current.component(.month, from: Date())
        let selectedMonth = Calendar.current.component(.month, from: v)
        return selectedMonth - currentMonth
      }
      .foldL(none: {}, some: { v in
        viewContent?.sctollTo(selectedMonth: v)
      })
  }

  private func setupView() {
    let viewContent = CalendarContentView(
      months: (viewModel?.months ?? [])
    )
    viewContent.delegate = self
    self.viewContent = viewContent
    let tapOutsideGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onClose))
    tapOutsideGestureRecognizer.cancelsTouchesInView = false
    tapOutsideGestureRecognizer.delegate = self
    viewContent.backgroundView.addGestureRecognizer(tapOutsideGestureRecognizer)
    calendarCloseByGestureRecognizer = CalendarCloseByGestureRecognizer(
      parentView: viewContent,
      animatedView: viewContent.contentView,
      gestureBounds: CGRect(x: 0, y: 0, width: 0, height: 75),
      onClose: {[unowned self] in
        self.onClose()
      }
    )
    view = viewContent
  }
}

extension CalendarViewController: CalendarContentViewDelegate {
  @objc func onClose() {
    onResult(nil)
    viewModel?.onClose()
  }

  func onSave() {
    guard let viewModel = self.viewModel else { return }
    self.onResult(viewModel.selectedDates)
    viewModel.onClose()
  }

  func onClearDates() {
     self.viewModel?.clearDates()
  }

  func onSelect(date: Date) {
    self.viewModel?.selectDate(selectedDate: date)
  }
}

extension CalendarViewController: CalendarViewModelDelegate {
  func onSelectedDatesDidChange(_ dates: SelectedDates) {
    viewContent?.onSelectedDatesDidChange(dates)
  }
}
