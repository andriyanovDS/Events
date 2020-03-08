//
//  DescriptionCellView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class DescriptionCellView: UICollectionViewCell {

  private struct Constants {
    static let animationDuration: CGFloat = 0.3
    static let addButtonSize: CGFloat = 27
  }

  var eventDescription: MutableDescription? {
    didSet {
      if let description = eventDescription {
        setupCell(description: description)
      }
    }
  }

  var selectAnimation: UIViewPropertyAnimator {
    let scaleAnimator = UIViewPropertyAnimator(
      duration: 0.3,
      dampingRatio: 0.7,
      animations: {[unowned self] in
        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
      }
    )
    let identityAnimator = UIViewPropertyAnimator(
      duration: 0.3,
      dampingRatio: 0.7,
      animations: {[unowned self] in
        self.transform = .identity
      }
    )
    scaleAnimator.addCompletion { _ in identityAnimator.startAnimation() }
    return scaleAnimator
  }

  var isLastCell: Bool = false {
    willSet (nextValue) {
      guard isLastCell != nextValue else { return }
      if nextValue == true {
        setupAddButton()
        return
      }
      addButton?.removeFromSuperview()
      addButton = nil
    }
  }

  var addButton: AddButton?

  private let titleLabel = UILabel()

  override var bounds: CGRect {
    didSet {
      addShadow(view: self, radius: 1.8)
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    backgroundColor = .white
    layer.cornerRadius = 10

    titleLabel.textAlignment = .center
    styleText(
      label: titleLabel,
      text: "",
      size: 14,
      color: .black,
      style: .medium
    )
    let skeletonView = UIView()
    skeletonView.style { v in
      v.layer.cornerRadius = 5
      v.backgroundColor = UIColor.gray200()
    }
    sv([titleLabel, skeletonView])
    titleLabel.centerHorizontally().top(5)
    skeletonView
      .right(5)
      .left(5)
      .bottom(30)
      .Top == titleLabel.Bottom + 5
  }

  private func setupCell(
    description: MutableDescription
  ) {
    titleLabel.text = description.title
  }

  private func setupAddButton() {
    let button = AddButton(frame: CGRect.zero)
    sv(button)
    button
      .right(-Constants.addButtonSize / 2)
      .top(-Constants.addButtonSize / 3)
      .width(Constants.addButtonSize)
      .height(Constants.addButtonSize)
    addButton = button
  }

  override func prepareForReuse() {
    eventDescription = nil
    titleLabel.text = nil
  }
}
