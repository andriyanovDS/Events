//
//  TextFormattingTipsVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 11/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class TextFormattingTipsVC: UIViewController, ViewModelBased {
  var viewModel: TextFormattingTipsViewModel!
  var textFormattingTipsView: TextFormattingTipsView?

  override func viewDidLoad() {
    super.viewDidLoad()

    viewModel = TextFormattingTipsViewModel()
    setupView()
  }

  private func setupView() {
    textFormattingTipsView = TextFormattingTipsView(tips: viewModel.tips)
    textFormattingTipsView?.closeButton.addTarget(
      self,
      action: #selector(onPressCloseButton),
      for: .touchUpInside
    )
    view = textFormattingTipsView
  }

  @objc private func onPressCloseButton() {
    viewModel.closeScreen()
  }
}
