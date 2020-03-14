//
//  EventDurationRange.swift
//  Events
//
//  Created by Дмитрий Андриянов on 09/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

struct EventDurationRange: Equatable, Codable {
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

  var localizedLabel: String {
    let formatString = NSLocalizedString("Event duration hours", comment: "Event duration hours plural")
    let minRangeLabelFnOption = min
      .map { durationRangeLabel(formatString: formatString)($0) }
      .orElse({ (max: Int) in String.localizedStringWithFormat(formatString, max) })

    return max
      .ap(minRangeLabelFnOption)
      .getOrElseL({ min
        .map { min in
          "\(NSLocalizedString("More than", comment: "Event duration hours"))"
          + " \(String.localizedStringWithFormat(formatString, min))"
        }
        .getOrElse(result: "")
      })
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.min == rhs.min && lhs.max == rhs.max
  }

  private func durationRangeLabel(formatString: String) -> (Int) -> (Int) -> String {
    return { (min: Int) in
      return { (max: Int) in "\(min) - \(String.localizedStringWithFormat(formatString, max))" }
    }
  }
}
