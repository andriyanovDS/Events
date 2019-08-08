//
//  LocationItem.swift
//  Events
//
//  Created by Дмитрий Андриянов on 14/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import SwiftIconFont

class LocationItem: UIButton {

  let label = UILabel()
  var text: String? {
    willSet (nextValue) {
      nextValue.foldL(
        none: {},
        some: { text in
          self.setupLabel(with: text)
      }
      )
    }
  }
  private lazy var iconView: UIImageView = {
    let image = UIImage(
      from: .materialIcon,
      code: "location.on",
      textColor: .black,
      backgroundColor: .clear,
      size: CGSize(width: 30, height: 30)
    )
    return UIImageView(image: image)
  }()

  override var isHighlighted: Bool {
    willSet (nextValue) {
      if nextValue == isHighlighted {
        return
      }
      self.backgroundColor = nextValue ? UIColor.gray200() : .clear
    }
  }

  var geocode: Geocode?
  var placeId: String?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupView() {
    layer.cornerRadius = 8
    setupIcon()
  }

  private func setupIcon() {
    self.addSubview(iconView)
    setupIconConstraints()
  }

  private func setupLabel(with text: String) {
    label.text = text
    label.textColor = UIColor.gray900()
    label.textAlignment = .left
    label.font = UIFont.init(
      name: "CeraPro-Medium",
      size: 16
    )
    self.addSubview(label)
    setupLabelConstraints()
  }

  private func setupIconConstraints() {
    iconView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
      iconView.heightAnchor.constraint(equalToConstant: 30),
      iconView.widthAnchor.constraint(equalToConstant: 30),
      iconView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      iconView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5)
      ])
  }

  private func setupLabelConstraints() {
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
      label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15)
      ])
  }
}
