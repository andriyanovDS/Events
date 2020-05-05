//
//  RootScreenViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow
import RxCocoa
import Promises
import UIKit.UIImage
import AVFoundation

class RootScreenViewModel: Stepper {
  let steps = PublishRelay<Step>()
  private let db: RootScreenRepository
  
  init(db: RootScreenRepository) {
    self.db = db
  }
  
  func loadEventList() -> Promise<[Event]> {
    db.eventList()
  }

  func openEvent(_ event: Event, sharedCardInfo: SharedEventCardInfo, sharedImage: UIImage?) {
		steps.accept(EventStep.event(
			event: event,
			sharedImage: sharedImage,
      sharedCardInfo: sharedCardInfo
		))
  }
}
