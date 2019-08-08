//
//  Result.swift
//  Events
//
//  Created by Дмитрий Андриянов on 28/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

extension Result where Success == Void {
  static var success: Result {
    return .success(())
  }
}
