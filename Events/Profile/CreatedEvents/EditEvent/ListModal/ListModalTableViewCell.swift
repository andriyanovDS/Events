//
//  ListModalTableViewCell.swift
//  Events
//
//  Created by Дмитрий Андриянов on 05.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class ListModalTableViewCell: UITableViewCell {
  let label = UILabel()

  static let reuseIdentifier = String(describing: LocationCell.self)

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    label.text = nil
  }

  private func setupView() {
    styleText(
      label: label,
      text: "",
      size: 18,
      color: .fontLabel,
      style: .medium
    )
    sv(label)
    label.left(20).top(10).right(10).bottom(10)
  }
}
