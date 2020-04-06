//
//  EventStep.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow
import Photos

indirect enum EventStep: Step {
  case login
  case home
  case profile
  case saved
  case events
	case event(event: Event, author: User, sharedImage: UIImage?)
	case eventDidComplete(userEvent: UserEvent)
	case createdEvents
	case createdEventsDidComplete
	case editEvent(event: Event)
	case editEventDidComplete
  case userDetails(user: User)
  case userDetailsDidComplete
  case createEvent
  case createEventDidComplete
  case imagePicker(
    selectedAssets: [PHAsset],
    onComplete: ([PHAsset]) -> Void
  )
  case imagePickerDidComplete
  case calendar(withSelectedDates: SelectedDates, onComplete: (SelectedDates?) -> Void)
  case calendarDidComplete
  case locationSearch (onResult: (Geocode) -> Void)
  case locationSearchDidCompete
  case searchBar
  case hintPopup(popup: HintPopup)
  case hintPopupDidComplete(nextStep: EventStep?)
  case textFormattingTips
  case textFormattingTipsDidComplete
  case permissionModal (withType: PermissionModalType)
  case permissionModalDidComplete
  case imagesPreview(
    assets: PHFetchResult<PHAsset>,
		sharedImage: SharedImage,
    selectedImageIndices: [Int],
    onImageDidSelected: (Int) -> Void
  )
  case imagesPreviewDidComplete
	case alert(
		title: String,
		message: String,
		actions: [UIAlertAction]
	)
  case listModal(
    title: String,
    buttons: [ListModalButton],
    onComplete: (ListModalButton) -> Void
  )
  case listModalDidComplete
	case datePickerModal(
		initialDate: Date,
		mode: UIDatePicker.Mode,
		onComplete: (Date) -> Void
	)
	case datePickerModalDidComplete
	case eventName(initialName: String?, onComplete: (String?) -> Void)
	case eventNameDidComplete
}
