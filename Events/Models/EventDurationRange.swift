//
//  EventDurationRange.swift
//  Events
//
//  Created by Дмитрий Андриянов on 09/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

struct EventDurationRange {
  let min: Int?
  let max: Int?
  
  init?(min: Int?, max: Int?) {
    
    let isRangeValid = min
      .chain({ min in
        max.map({ max in min <= max })
      })
      .getOrElse(result: true)
    
    if !isRangeValid {
      return nil
    }
    
    self.min = min
    self.max = max
  }
}
