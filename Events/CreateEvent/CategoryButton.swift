//
//  CategoryButton.swift
//  Events
//
//  Created by Дмитрий Андриянов on 11/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class CategoryButton: UIButtonScaleOnPress {
  let category: CategoryId
	private let categoryImageView = UIImageView()

  init(category: CategoryId) {
    self.category = category
    super.init(frame: CGRect.zero)
    setupView()
  }
	
	deinit {
		categoryImageView.removeFromSuperview()
	}

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    layer.borderWidth = 3
    layer.cornerRadius = 7
    layer.borderColor = UIColor.gray200().cgColor
    contentHorizontalAlignment = .left
    contentVerticalAlignment = .bottom

    titleLabel?.numberOfLines = 0
    let image = UIImage(named: category.rawValue)
    categoryImageView.image = image
    categoryImageView.clipsToBounds = true
    categoryImageView.contentMode = .scaleAspectFit

    let label = UILabel()
    label.numberOfLines = 2
    styleText(
      label: label,
      text: category.translatedLabel(),
      size: 16,
      color: .gray900(),
      style: .bold
    )
    label.textAlignment = .center
    sv(categoryImageView, label)
    categoryImageView
			.top(10)
		  .width(60)
		  .height(60)
			.centerHorizontally()
    label.bottom(10).left(10).right(10).centerHorizontally()
    label.Top == categoryImageView.Bottom + 7
  }
}
