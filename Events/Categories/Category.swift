//
//  Category.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

struct Category {
  let id: CategoryId
  let name: String

  init(id: CategoryId) {
    self.id = id
    self.name = id.translatedLabel()
  }
}

enum CategoryId: String, CaseIterable {
  case art, workshop, food, health, sport

  func translatedLabel() -> String {
    switch self {
    case .art:
      return "Искусство и развлечения"
    case .workshop:
      return "Курсы и тренинги"
    case .food:
      return "Еда и напитки"
    case .health:
      return "Здоровье"
    case .sport:
      return "Спорт и занятия на открытом воздухе"
    }
  }
}
