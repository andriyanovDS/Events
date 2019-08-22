//
//  CategoriesViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

class CategoriesViewModel {
  
  let categories: [Category]
  
  init() {
    categories = [
      Category(id: .art),
      Category(id: .workshop),
      Category(id: .food),
      Category(id: .health),
      Category(id: .sport)
    ]
  }
}
