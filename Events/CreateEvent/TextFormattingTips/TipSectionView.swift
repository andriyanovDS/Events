//
//  TipSectionView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 13/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class TipSectionView: UIView {
  let tip: Tip
  private let titleView = UIView()
  private let exampleView = UIView()
  private let descriptionLabel = UILabel()
  private var textContainer: NSTextContainer?

  init(tip: Tip) {
    self.tip = tip
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    setupTitleView()
    setupExampleView()
    setupDescriptionLabel()
  }

  private func setupTitleView() {
    let titleLabel = UILabel()
    let borderView = UIView()
    styleText(
      label: titleLabel,
      text: tip.title,
      size: 18,
      color: .gray900(),
      style: .bold
    )
    borderView.backgroundColor = .gray200()
    sv(titleView.sv(titleLabel, borderView))
    titleView.top(0).width(100%)
    borderView.bottom(0).width(100%).height(1)
    titleLabel.bottom(10).left(0).top(0)
  }

  private func setupExampleLabel() -> UITextView {
    let attributes = [NSAttributedString.Key.font: UIFont.init(name: "CeraPro", size: 16)]
    let attrString = NSAttributedString(string: tip.example, attributes: attributes)
    let textStorage = TextFormattingsTextStorage(fontSize: 16)
    textStorage.append(attrString)
    let layoutManager = NSLayoutManager()
    let containerSize = CGSize(
      width: 150,
      height: CGFloat.greatestFiniteMagnitude
    )
    let container = NSTextContainer(size: containerSize)
    container.widthTracksTextView = true
    layoutManager.addTextContainer(container)
    textStorage.addLayoutManager(layoutManager)
    let textViewFrame = CGRect(
      x: 0,
      y: 0,
      width: containerSize.width,
      height: containerSize.height
    )
    return UITextView(frame: textViewFrame, textContainer: container)
  }

  private func setupExampleView() {
    let exampleLabel = setupExampleLabel()
    exampleLabel.style({ v in
      v.sizeToFit()
    })
    addShadow(view: exampleView, radius: 3)
    exampleView.backgroundColor = .white
    exampleView.layer.cornerRadius = 7
    exampleView.sv(exampleLabel)
    sv(exampleView)
    exampleView.Top == titleView.Bottom + 20
    exampleView.left(0).width(150)
  }

  private func setupDescriptionLabel() {
    styleText(
      label: descriptionLabel,
      text: tip.description,
      size: 16,
      color: .gray900(),
      style: .regular
    )
    descriptionLabel.style({ v in
      v.numberOfLines = 0
      v.lineBreakMode = .byWordWrapping
    })
    sv(descriptionLabel)
    descriptionLabel.Left == exampleView.Right + 20
    descriptionLabel.Top == exampleView.Top + 10
    descriptionLabel.right(0)
  }
}
