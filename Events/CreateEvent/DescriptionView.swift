//
//  DescriptionView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 11/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class DescriptionView: UIView {
  let textView = UITextView()
  let submitButton = ButtonWithBorder()
  private let contentView = UIView()
  private let label = UILabel()

  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func showHint() {
    let hintView = setupHintView()
    UIView.animate(
      withDuration: 0.3,
      animations: {
        hintView.alpha = 1
      },
      completion: nil
    )
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      UIView.animate(
        withDuration: 0.3,
        animations: {
          hintView.alpha = 0
        },
        completion: { _ in
          hintView.removeFromSuperview()
        }
      )
    }
  }

  private func setupView() {
    backgroundColor = .white

    styleText(
      label: label,
      text: "Расскажи о мероприятии",
      size: 26,
      color: .gray900(),
      style: .bold
    )
    styleText(
      textView: textView,
      text: "",
      size: 16,
      color: .gray800(),
      style: .medium
    )
    styleText(
      button: submitButton,
      text: "Далее",
      size: 20,
      color: .blue,
      style: .medium
    )

    textView.style({ v in
      v.layer.cornerRadius = 5
      v.backgroundColor = UIColor.gray100(alpha: 0.4)
    })

    submitButton.contentEdgeInsets = UIEdgeInsets(
      top: 7,
      left: 0,
      bottom: 7,
      right: 0
    )
    submitButton.layer.borderColor = UIColor.blue().cgColor

    sv(contentView.sv([label, textView, submitButton]))

    setupConstraints()

    showHint()
  }

  private func setupHintView() -> UIView {
    let hintView = HintView(
      titleText: "Оформите свой текст",
      descriptionText: "Форматируйте текст, используя специальные символы, чтобы сделать текст более подробным и ясным",
      linkText: "Нажмите, чтобы узнать больше"
    )
    hintView.alpha = 0
    contentView.sv(hintView)

    hintView.width(220)
    hintView.Top == textView.Top + 20
    hintView.Right == textView.Right - 10
    return hintView
  }

  private func setupConstraints() {
    contentView.left(20).right(20).centerInContainer()
    contentView.Top == safeAreaLayoutGuide.Top
    contentView.Bottom == safeAreaLayoutGuide.Bottom

    label.top(20).left(0).right(0)
    align(vertically: [label, textView])
    layout(
      |-label-|,
      10,
      |-textView-|,
      15,
      |-submitButton.centerHorizontally().width(200)-|,
      30
    )
  }
}
