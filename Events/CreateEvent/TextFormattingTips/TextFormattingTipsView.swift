//
//  TextFormattingTipsView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 11/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import SwiftIconFont

class TextFormattingTipsView: UIView {
  let tips: [Tip]
  let closeButton = UIButtonScaleOnPress()
  private let contentView = UIView()
  private let titleLabel = UILabel()

  init(tips: [Tip]) {
    self.tips = tips
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    backgroundColor = .background

    sv(contentView)
    contentView.Top == safeAreaLayoutGuide.Top
    contentView.Bottom == safeAreaLayoutGuide.Bottom
    contentView
      .centerInContainer()
      .fillContainer()
      .left(20)
      .right(20)

    setupHeader()
    setupSections()
  }

  private func setupHeader() {
    styleText(
      label: titleLabel,
      text: "Орформите \nсвой текст",
      size: 24,
      color: .fontLabel,
      style: .bold
    )
    let image = UIImage(
      from: .materialIcon,
      code: "cancel",
      textColor: .fontLabel,
      backgroundColor: .clear,
      size: CGSize(width: 30, height: 30)
    )
    titleLabel.style({ v in
      v.numberOfLines = 0
      v.lineBreakMode = .byWordWrapping
      v.textAlignment = .center
    })
    closeButton.setImage(image, for: .normal)

    contentView.sv(titleLabel, closeButton)
    titleLabel.centerHorizontally().top(10)
    closeButton.right(20)
    closeButton.CenterY == titleLabel.CenterY
  }

  private func setupSections() {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fillProportionally
    stackView.spacing = 0
    tips
      .map { TipSectionView(tip: $0) }
      .forEach {stackView.addArrangedSubview($0) }

    contentView.sv(stackView)
    stackView.Top == titleLabel.Bottom + 30
    stackView.left(20).right(20).bottom(0)
  }
}
