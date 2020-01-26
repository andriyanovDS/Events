//
//  RootScreenView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 26/01/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class RootScreenView: UIView {
  var locationButton: FilterButton!
  var datesButton: FilterButton!
  let defaultDatesButtonLabel = NSLocalizedString(
     "Dates",
     comment: "Select calendar dates label"
   )
  private let buttonsContainerView = UIView()
  private let searchBarView: UIView

  init(
    searchBarView: UIView
  ) {
    self.searchBarView = searchBarView
    super.init(frame: CGRect.zero)

    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setLocationButtonLabelText(_ text: String?) {
    let labelText = text ?? NSLocalizedString(
      "Select location",
      comment: "Select location button: empty location"
    )
    locationButton.setTitle(labelText, for: .normal)
    locationButton.isEnabled = true
    if locationButton.alpha == 0 {
      UIView.animate(withDuration: 0.15, animations: {
        self.locationButton.alpha = 1
        self.layoutIfNeeded()
      })
    }
  }

  func setDatesButtonLabelText(_ text: String?) {
    if text == datesButton.title(for: .normal) { return }

    _ = text.foldL(
      none: {
        datesButton.style { v in
          v.isFilterEmpty = true
          v.layer.borderWidth = 1
          v.setTitleColor(UIColor.gray600(), for: .normal)
          v.backgroundColor = .white
          v.setTitle(defaultDatesButtonLabel, for: .normal)
        }
      },
      some: { labelText in
        datesButton.style { v in
          v.isFilterEmpty = false
          v.layer.borderWidth = 0
          v.setTitleColor(.white, for: .normal)
          v.backgroundColor = UIColor.lightBlue()
          v.setTitle(labelText, for: .normal)
        }
      }
    )
  }

  private func setupView() {
    backgroundColor = .white
    let titleLabel = UILabel()
    styleText(
      label: titleLabel,
      text: NSLocalizedString("Choose your next experience", comment: "Home screen title"),
      size: 24,
      color: .black,
      style: .bold
    )

    titleLabel.numberOfLines = 2
    sv(searchBarView, buttonsContainerView, titleLabel)
    setupDatesButton()
    setupLocationButton()

    buttonsContainerView.height(30)

    layout(
      30,
      |-0-searchBarView-0-|,
      8,
      |-20-buttonsContainerView-20-|,
      20,
      |-20-titleLabel-20-|
    )
  }

  private func setupDatesButton() {
    let button = FilterButton(label: defaultDatesButtonLabel)
    datesButton = button
    button.hero.id = CALENDAR_SHARED_ID
    buttonsContainerView.sv(button)
    button.left(0).top(0)
  }

  private func setupLocationButton() {
    let button = FilterButton(label: "")
    locationButton = button
    locationButton.isEnabled = false
    locationButton.alpha = 0
    buttonsContainerView.sv(button)
    button.top(0)
    button.Left == datesButton.Right + 7
  }
}
