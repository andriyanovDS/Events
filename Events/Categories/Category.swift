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
}

enum CategoryId {
    case art, workshop, food, health, sport
}
