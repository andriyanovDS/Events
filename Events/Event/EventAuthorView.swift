//
//  EventAuthorView.swift
//  Events
//
//  Created by Dmitry on 24.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class EventAuthorView: UIStackView {
  let avatarImageView = UIImageView()
  let nameLabel = UILabel()
  private let titleLabel = UILabel()
	
	init() {
		super.init(frame: CGRect.zero)
		setupView()
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
  struct Constants {
    static let avatarImageSize: CGSize = CGSize(width: 70.0, height: 70.0)
	}
	
	private func setupView() {
		styleText(
			label: titleLabel,
			text: NSLocalizedString("Author", comment: "Event user section title"),
			size: 20,
			color: .fontLabel,
			style: .bold
		)
		styleText(
			label: nameLabel,
			text: "",
			size: 16,
			color: .fontLabel,
			style: .medium
		)
		avatarImageView.style { v in
			v.clipsToBounds = true
			v.backgroundColor = .skeletonBackground
			v.contentMode = .scaleAspectFill
      let size = Constants.avatarImageSize
      v.layer.cornerRadius = size.width / 2.0
      v.width(size.width).height(size.height)
		}
		
		axis = .vertical
		alignment = .leading
		spacing = 10
    isLayoutMarginsRelativeArrangement = true
    layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
		addArrangedSubview(titleLabel)
		addArrangedSubview(avatarImageView)
		addArrangedSubview(nameLabel)
	}
}
