//
//  CalendarHeaderView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 19/01/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import SwiftIconFont

class CalendarHeaderView: UIView {
  let closeButton = UIButtonScaleOnPress()
  private let titleLabel = UILabel()
  private let weekDaysStackView = UIStackView()
  private let unselectedDatesTitle = NSLocalizedString(
    "Select dates",
    comment: "Calendar: title, dates unselected"
  )

  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setSelectedDatesTitle(_ title: String?) {
    titleLabel.text = title.getOrElse(result: unselectedDatesTitle)
  }

  private func setupWeekDays() {
    var symbols = Calendar.current.weekdaySymbols
    let firstSymbol = symbols.remove(at: 0)
    symbols.append(firstSymbol)
    symbols
      .map { String($0.prefix(1)) }
      .map { v in
        let label = UILabel()
        styleText(
          label: label,
          text: v,
          size: 20,
          color: .fontLabelDescription,
          style: .regular
        )
        label.textAlignment = .center
        return label
      }
      .forEach { weekDaysStackView.addArrangedSubview($0) }
    weekDaysStackView.style { v in
      v.axis = .horizontal
      v.distribution = .fillEqually
      v.alignment = .fill
    }
  }

  private func setupView() {
    styleText(
      label: titleLabel,
      text: unselectedDatesTitle,
      size: 16,
      color: .fontLabel,
      style: .medium
    )
    let image = UIImage(
      from: .fontAwesome,
      code: "times",
      textColor: .fontLabel,
      backgroundColor: .clear,
      size: CGSize(width: 30, height: 30)
    )
    closeButton.setImage(image, for: .normal)
    setupWeekDays()

    sv(titleLabel, closeButton, weekDaysStackView)
    titleLabel.centerHorizontally().top(20).height(20)
    closeButton.CenterY == titleLabel.CenterY - 1
    closeButton.left(20)
    weekDaysStackView.Top == titleLabel.Bottom + 20
    weekDaysStackView.left(25).right(25).bottom(0)
  }
}
