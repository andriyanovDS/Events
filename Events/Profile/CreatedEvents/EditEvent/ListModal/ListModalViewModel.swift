//
//  ListModalViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxCocoa
import RxFlow

protocol ListModalButton {
  var labelText: String { get }
  var isSelected: Bool { get }
}

class ListModalViewModel: Stepper, ScreenWithResult {
  let steps = PublishRelay<Step>()
  var onResult: ((ListModalButton) -> Void)!
  private let buttons: [ListModalButton]
  var buttonLabelTexts: [String] {
    buttons.map(\.labelText)
  }

  init(buttons: [ListModalButton]) {
    self.buttons = buttons
  }

  func buttonLabel(at index: Int) -> String {
    buttons[index].labelText
  }

  func onSelectButton(at index: Int) {
    let button = buttons[index]
    onResult(button)
  }

  func willCloseWithoutChanges() {
    let selectedButton = buttons.first(where: { $0.isSelected })
    if let button = selectedButton {
      onResult(button)
    }
  }

  func onClose() {
    steps.accept(EventStep.listModalDidComplete)
  }
}
