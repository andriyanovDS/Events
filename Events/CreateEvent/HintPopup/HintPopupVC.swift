//
//  HintPopupVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class HintPopupVC: UIViewController, UIGestureRecognizerDelegate {
  private var popupView: HintPopupView?
  private let viewModel: HintPopupViewModel
  private let popup: HintPopup

  init(hintPopup: HintPopup, viewModel: HintPopupViewModel) {
    self.popup = hintPopup
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
  }

  private func setupView() {
    popupView = HintPopupView(popup: popup)
    let hintGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onPressHint))
    let backgroundGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onClosePopup))
    backgroundGestureRecognizer.cancelsTouchesInView = false
    backgroundGestureRecognizer.delegate = self
    popupView?.hintButton.addGestureRecognizer(hintGestureRecognizer)
    popupView?.backgroundView.addGestureRecognizer(backgroundGestureRecognizer)
    view = popupView
  }

  @objc func onPressHint() {
    viewModel.openTextFormattingTips()
  }

  @objc func onClosePopup() {
    viewModel.closePopup()
  }
}
