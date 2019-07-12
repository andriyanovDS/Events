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
            Category(id: CategoryId.art, name: "Arts and Entertainment"),
            Category(id: .workshop, name: "Classes and workshops"),
            Category(id: .food, name: "Food and drink"),
            Category(id: .health, name: "Health and welness"),
            Category(id: .sport, name: "Sport and outdoors")
        ]
    }
}
