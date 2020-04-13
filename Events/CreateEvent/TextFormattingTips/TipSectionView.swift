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
    setupDescriptionTextLabel()
    setupExampleView()
  }

  private func setupTitleView() {
    let titleLabel = UILabel()
    let borderView = UIView()
    styleText(
      label: titleLabel,
      text: tip.title,
      size: 18,
      color: .fontLabel,
      style: .bold
    )
    borderView.backgroundColor = .border
    sv(titleView.sv(titleLabel, borderView))
    titleView.top(0).width(100%)
    borderView.bottom(0).width(100%).height(1)
    titleLabel.bottom(10).left(0).top(0)
  }

  private func setupExampleTextView() -> UITextView {
    let attributes = [NSAttributedString.Key.font: UIFont.init(name: "Montserrat", size: 16)]
    let attrString = NSAttributedString(
      string: tip.example,
      attributes: attributes as [NSAttributedString.Key: Any]
    )
    let textStorage = TextFormattingsTextStorage(fontSize: 16)
    textStorage.append(attrString)
    let layoutManager = NSLayoutManager()
    let containerSize = CGSize.zero
    let container = NSTextContainer(size: containerSize)
    container.widthTracksTextView = true
    layoutManager.addTextContainer(container)
    textStorage.addLayoutManager(layoutManager)
    let textViewFrame = CGRect.zero
    return UITextView(frame: textViewFrame, textContainer: container)
  }

  private func setupExampleView() {
    let exampleTextView = setupExampleTextView()
    exampleTextView.style({ v in
      v.sizeToFit()
      v.textAlignment = .center
      v.layer.cornerRadius = 5
    })
    addShadow(view: exampleView, radius: 3)
    exampleView.sv(exampleTextView)
    sv(exampleView)
    exampleView.left(0)
    exampleView.Top == descriptionLabel.Top
    exampleView.Bottom == descriptionLabel.Bottom
    exampleView.Right == self.CenterX
    exampleTextView.top(0).right(5).left(5).bottom(0)
  }

  private func setupDescriptionTextLabel() {
    styleText(
      label: descriptionLabel,
      text: tip.description,
      size: 16,
      color: .fontLabel,
      style: .regular
    )
    descriptionLabel.style({ v in
      v.numberOfLines = 0
      v.lineBreakMode = .byWordWrapping
    })
    sv(descriptionLabel)
    descriptionLabel.Top == titleView.Bottom + 20
    descriptionLabel.right(0)
    descriptionLabel.Left == self.CenterX + 15
  }
}
