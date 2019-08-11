//
//  TextFormattingTipsViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 11/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

class TextFormattingTipsViewModel {
  weak var coordinator: TextFormattingTipsCoordinator?

}

protocol TextFormattingTipsCoordinator: class {
  func closeTextFormattingTips()
}
