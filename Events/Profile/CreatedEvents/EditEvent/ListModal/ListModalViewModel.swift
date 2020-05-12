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

class ListModalViewModel: Stepper, ResultProvider {
  let steps = PublishRelay<Step>()
  let onResult: ResultHandler<ListModalButton>
  private let buttons: [ListModalButton]
  var buttonLabelTexts: [String] {
    buttons.map(\.labelText)
  }

  init(buttons: [ListModalButton], onResult: @escaping ResultHandler<ListModalButton>) {
    self.buttons = buttons
    self.onResult = onResult
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
