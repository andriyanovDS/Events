//
//  HintPopupViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

class HintPopupViewModel: Stepper {
  let steps = PublishRelay<Step>()

  func openTextFormattingTips() {
    steps.accept(EventStep.hintPopupDidComplete(nextStep: .textFormattingTips))
  }

  func closePopup() {
    steps.accept(EventStep.hintPopupDidComplete(nextStep: nil))
  }
}

protocol HintPopupViewCoordinator: class {
  func openTextFormattingTips()
  func closePopup(onComplete: (() -> Void)?)
}
