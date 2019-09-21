//
//  EventStep.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow

indirect enum EventStep: Step {
  case login
  case home
  case profile
  case saved
  case events
  case userDetails(user: User)
  case userDetailsDidComplete
  case createEvent
  case createEventDidComplete
  case imagePicker(onComplete: ([UIImage]) -> Void)
  case imagePickerDidComplete
  case imagesPreview
  case calendar(withSelectedDates: SelectedDates, onComplete: (SelectedDates) -> Void)
  case calendarDidComplete
  case locationSearch (onResult: (Geocode) -> Void)
  case locationSearchDidCompete
  case searchBar
  case hintPopup(popup: HintPopup)
  case hintPopupDidComplete(nextStep: EventStep?)
  case textFormattingTips
  case permissionModal (withType: PermissionModalType)
  case permissionModalDidComplete
}