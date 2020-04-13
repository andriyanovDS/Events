//
//  CalendarMonthView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 20/01/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class CalendarMonthView: UIView {
  private let monthLabel = UILabel()
  private let weekStackView = UIStackView()
  private let monthName: String
  private let days: [[Day?]]
  private var dayButtons: [String: DayButton] = [:]

  var buttons: [String: DayButton] {
    self.dayButtons
  }

  init(month: Month) {
    monthName = month.title
    days = month.days
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupDay(_ day: Day?) -> DayButton {
    return day
      .map { v -> DayButton in
        let button = DayButton(day: v)
        styleText(
          button: button,
          text: String(v.dayOfMonth),
          size: 16,
          color: v.isInPast
            ? UIColor.fontLabelDescription
            : .fontLabel,
          style: .regular
        )
        button.highlightState = .notSelected
        return button
      }
    .alt { DayButton(day: nil) }
  }

  private func setupWeek(days: [Day?]) -> UIView {
    let weekStackView = UIStackView()
    weekStackView.style { v in
      v.distribution = .fillEqually
      v.alignment = .fill
      v.axis = .horizontal
    }
    let dayButtons = days.map(setupDay)

    dayButtons.forEach { v in
      guard let date = v.date else {
        return
      }
      self.dayButtons.updateValue(v, forKey: dateToKey(date))
    }
    dayButtons.forEach(weekStackView.addArrangedSubview)
    return weekStackView
  }

  private func setupView() {
    styleText(
      label: monthLabel,
      text: monthName,
      size: 18,
      color: .fontLabel,
      style: .medium
    )

    let weeksStackView = UIStackView()
    weeksStackView.style { v in
      v.distribution = .equalSpacing
      v.alignment = .fill
      v.axis = .vertical
    }
    days
      .map { setupWeek(days: $0) }
      .forEach { v in
        weeksStackView.addArrangedSubview(v)
        v.height(40)
      }

    sv(monthLabel, weeksStackView)
    monthLabel.top(10).left(15)
    weeksStackView.left(15).right(15)
    weeksStackView.Top == monthLabel.Bottom + 10
    weeksStackView.bottom(0)
  }
}
