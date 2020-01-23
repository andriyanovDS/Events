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
  var viewModel: CalendarViewModel! {
    didSet {
      viewModel.delegate = self
    }
  }
  var onResult: ((SelectedDates?) -> Void)!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
  }
  
  override func viewDidLayoutSubviews() {
    onSelectedDatesDidChange(viewModel.selectedDates)
    viewModel.selectedDates.from
      .map { v in
        let currentMonth = Calendar.current.component(.month, from: Date())
        let selectedMonth = Calendar.current.component(.month, from: v)
        return selectedMonth - currentMonth
      }
      .foldL(none: {}, some: { v in
        viewContent?.sctollTo(selectedMonth: v)
      })
  }
  
  @objc func closeModal() {
    onResult(nil)
    viewModel.onClose()
  }

  private func setupView() {
    viewContent = CalendarContentView(
      months: viewModel.months,
      onClose: closeModal,
      onSave: { [weak self] in
        guard let self = self else {
          return
        }
        self.onResult(self.viewModel.selectedDates)
        self.viewModel.onClose()
      },
      onSelectDate: viewModel.selectDate,
      onClearDates: viewModel.clearDates
    )
    let tapOutsideGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeModal))
    tapOutsideGestureRecognizer.cancelsTouchesInView = false
    tapOutsideGestureRecognizer.delegate = self
    viewContent?.backgroundView.addGestureRecognizer(tapOutsideGestureRecognizer)
    view = viewContent
  }
}

extension CalendarViewController: CalendarViewModelDelegate {
  func onSelectedDatesDidChange(_ dates: SelectedDates) {
    viewContent?.onSelectedDatesDidChange(dates)
  }
}
