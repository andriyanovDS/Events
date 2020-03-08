//
//  CategoryView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 11/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class CategoriesView: UIView, CreateEventView {
  weak var delegate: CategoriesViewDelegate?
  private let categoryButtons: [CategoryButton]
  private let contentView = UIView()
  private let titleLabel = UILabel()
  private let descriptionLabel = UILabel()
  private let columnsCount = 2
  private let contentViewPadding: CGFloat = 20

  init() {
    categoryButtons = CategoryId.allCases.map {
      CategoryButton(category: $0)
    }
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    backgroundColor = .white

    styleText(
      label: titleLabel,
      text: NSLocalizedString("Category", comment: "Create event: category section title"),
      size: 26,
      color: .gray900(),
      style: .bold
    )

    styleText(
      label: descriptionLabel,
      text: NSLocalizedString(
        "Which category event belongs to?",
        comment: "Create event: category section description"
      ),
      size: 18,
      color: .gray400(),
      style: .regular
    )
    descriptionLabel.numberOfLines = 2

    sv(contentView.sv([titleLabel, descriptionLabel]))
    setupConstraints()
    setupCategoryButtons()
  }

  private func setupCategoryButtons() {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.spacing = 10
    let chunks = categoryButtons.chunks(columnsCount)
    chunks.forEach({ chunk in
      let chunckStackView = UIStackView()
      chunckStackView.axis = .horizontal
      chunckStackView.alignment = .fill
      chunckStackView.distribution = .fill
      chunckStackView.spacing = 10

      chunk.forEach { button in
        let width = (UIScreen.main.bounds.width - contentViewPadding * 2 - 10) / 2
        button.width(width).height(110)
        chunckStackView.addArrangedSubview(button)
      }
      stackView.addArrangedSubview(chunckStackView)
    })
    categoryButtons.forEach { $0.addTarget(
      self,
      action: #selector(onPressCategoryButton(_:)),
      for: .touchUpInside
    )}
    contentView.sv(stackView)
    stackView.Top == descriptionLabel.Bottom + 30
  }

  private func setupConstraints() {
    contentView
      .left(contentViewPadding)
      .right(contentViewPadding)
      .centerInContainer()
    contentView.Top == safeAreaLayoutGuide.Top
    contentView.Bottom == safeAreaLayoutGuide.Bottom

    titleLabel
      .top(20%)
      .left(0)
      .right(0)

    align(vertically: [titleLabel, descriptionLabel])

    layout(
      |-titleLabel-|,
      8,
      |-descriptionLabel-|
    )
  }

  @objc private func onPressCategoryButton(_ button: CategoryButton) {
    delegate?.onSelect(category: button.category)
    delegate?.openNextScreen()
  }
}

protocol CategoriesViewDelegate: CreateEventViewDelegate {
  func onSelect(category: CategoryId)
}
