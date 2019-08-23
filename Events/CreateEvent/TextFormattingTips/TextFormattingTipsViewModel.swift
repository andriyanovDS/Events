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

  let tips = [
    Tip(
      title: "Жирный",
      example: "*Внимание!* Начало мероприятия перенесено на 11:00",
      description: "Чтобы выделить текст жирным поствьте вокруг него звездочки: *ваш текст*"
    ),
    Tip(
      title: "Курсив",
      example: "Прошу обратить внимание на этот очень _важный_ момент",
      description: "Чтобы выделить текст курсивом используйте символ подчеркивания с обеих сторон текста: _ваш текст_"
    ),
    Tip(
      title: "Зачеркивание",
      example: "Будет очень ~важный~ интересный гость",
      description: "Чтобы выделить текст курсивом используйте символ \"тильда\" с обеих сторон текста: ~ваш текст~"
    )
  ]

  func closeScreen() {
    coordinator?.closeTextFormattingTips()
  }
}

protocol TextFormattingTipsCoordinator: class {
  func closeTextFormattingTips()
}
