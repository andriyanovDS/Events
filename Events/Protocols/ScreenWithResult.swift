//
//  ScreenWithResult.swift
//  Events
//
//  Created by Дмитрий Андриянов on 18/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Foundation

protocol ScreenWithResult {
  associatedtype ResultType
  var onResult: ((ResultType) -> Void)! { get set }
}
