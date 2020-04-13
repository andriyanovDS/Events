//
//  CalendarContentView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 19/01/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import Hero

let calendarSharedElementId = "CALENDAR_SHARED_ID"

class CalendarContentView: UIView {
  let backgroundView = UIView()
  let contentView = UIView()
  private var days: [String: DayButton] = [:]
  private let headerView = CalendarHeaderView()
  private let footerView = CalendarFooterView()
  private let datesScrollView = UIScrollView()

  private let months: [Month]
  weak var delegate: CalendarContentViewDelegate?

  init(
    months: [Month]
  ) {
    self.months = months
    super.init(frame: CGRect.zero)

    setupView()
    addHandlers()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func onSelectedDatesDidChange(_ dates: SelectedDates) {
    let dateToButtonHighlightState = dateToButtonHighlightStateFn(selectedDates: dates)
    headerView.setSelectedDatesTitle(selectedDatesToTitle(dates))

    footerView.setIsClearButtonEnabled(dates.from != nil || dates.to != nil)

    days
      .values
      .forEach { v in
        v.highlightState = v.date
          .map(dateToButtonHighlightState)
          .getOrElse(result: .notSelected)
      }
  }

  func scrollTo(selectedMonth index: Int) {
    let monthHeight = datesScrollView.contentSize.height / CGFloat(months.count)
    let offsetPoint = CGPoint(
      x: 0,
      y: monthHeight * CGFloat(index)
    )
    datesScrollView.setContentOffset(offsetPoint, animated: false)
  }

  private func addHandlers() {
    headerView.closeButton.addTarget(
      self,
      action: #selector(onPressCloseButton),
      for: .touchUpInside
    )

    footerView.clearButton.addTarget(
       self,
       action: #selector(onPressClearButton),
       for: .touchUpInside
     )

     footerView.saveButton.addTarget(
       self,
       action: #selector(onPressSaveButton),
       for: .touchUpInside
     )
  }

  private func setupDates() -> UIView {
    let monthsStackView = UIStackView()

    datesScrollView.showsVerticalScrollIndicator = false
    monthsStackView.style { v in
      v.distribution = .fill
      v.alignment = .fill
      v.axis = .vertical
      v.spacing = 10
    }

    let monthViews = months.map { CalendarMonthView(month: $0) }
    days = monthViews
      .map { $0.buttons }
      .reduce(into: [:], { acc, buttons in
        acc.merge(buttons, uniquingKeysWith: { v1, _ in v1 })
      })
    days
      .values
      .forEach { $0.addTarget(self, action: #selector(onPressDayButton), for: .touchUpInside) }
    monthViews.forEach(monthsStackView.addArrangedSubview)

    datesScrollView.sv(monthsStackView)
    monthsStackView.fillContainer()
    monthsStackView.Width == datesScrollView.Width
    return datesScrollView
  }

  private func setupView() {
    isOpaque = false
    backgroundColor = .clear
    backgroundView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)

    contentView.hero.id = calendarSharedElementId
    let datesView = setupDates()
    contentView.style { v in
      v.backgroundColor = .background
      v.layer.cornerRadius = 10
    }

    sv(backgroundView, contentView.sv(headerView, datesView, footerView))
    backgroundView.fillContainer()

    contentView
      .top(safeAreaInsets.top + 130)
      .left(10)
      .right(10)
      .height(50%)
      .layout(
        0,
        |-headerView-|,
        10,
        |-datesView-|,
        |-footerView-|,
        0
      )
  }

  // MARK: Press handlers

  @objc private func onPressDayButton(_ button: DayButton) {
    guard let date = button.date else { return }
    delegate?.onSelect(date: date)
  }

  @objc private func onPressCloseButton() {
    delegate?.onClose()
  }

  @objc private func onPressClearButton() {
    delegate?.onClearDates()
  }

  @objc private func onPressSaveButton() {
    delegate?.onSave()
  }
}

protocol CalendarContentViewDelegate: class {
  func onClose()
  func onSave()
  func onSelect(date: Date)
  func onClearDates()
}
