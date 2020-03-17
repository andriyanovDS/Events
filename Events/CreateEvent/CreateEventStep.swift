//
//  CreateEventStep.swift
//  Events
//
//  Created by Дмитрий Андриянов on 07/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import RxFlow
import Photos.PHAsset
import Photos.PHFetchResult

enum CreateEventStep: Step {
  case
		location(onResult: (Geocode) -> Void),
		locationDidComplete,
    date(onResult: (DateScreenResult) -> Void),
    dateDidComplete,
    category(onResult: (CategoryId) -> Void),
    categoryDidComplete,
    description(onResult: ([DescriptionWithAssets]) -> Void),
    descriptionDidComplete
}
