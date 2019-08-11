//
//  HintPopupViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

class HintPopupViewModel {

  weak var coordinator: HintPopupViewCoordinator?

  func openTextFormattingTips() {
    coordinator?.closePopup(onComplete: {
      self.coordinator?.openTextFormattingTips()
    })
  }

  func closePopup() {
    coordinator?.closePopup(onComplete: nil)
  }
}

protocol HintPopupViewCoordinator: class {
  func openTextFormattingTips()
  func closePopup(onComplete: (() -> Void)?)
}
