//
//  ImagesPreviewViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import RxFlow
import RxCocoa

class ImagesPreviewViewModel: Stepper {
  let steps = PublishRelay<Step>()

  func onCloseModal() {
    steps.accept(EventStep.imagesPreviewDidComplete)
  }
}
