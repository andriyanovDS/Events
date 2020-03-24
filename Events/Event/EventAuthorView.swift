//
//  EventAuthorView.swift
//  Events
//
//  Created by Dmitry on 24.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class EventAuthorView: UIStackView {
	weak var delegate: EventViewSectionDelegate? {
		didSet {
			attemptToLoadAvatarImage()
		}
	}
	private let author: User
	private let titleLabel = UILabel()
	private let avatarImageView = UIImageView()
	private let nameLabel = UILabel()
	
	init(author: User) {
		self.author = author
		super.init(frame: CGRect.zero)
		setupView()
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private struct Constants {
		static let avatarImageSize: CGFloat = 70.0
	}
	
	private func setupView() {
		styleText(
			label: titleLabel,
			text: NSLocalizedString("Organizator", comment: "Event user section title"),
			size: 20,
			color: .black,
			style: .bold
		)
		styleText(
			label: nameLabel,
			text: author.fullName,
			size: 16,
			color: .black,
			style: .medium
		)
		avatarImageView.style { v in
			v.clipsToBounds = true
			v.contentMode = .scaleAspectFill
			v.layer.cornerRadius = Constants.avatarImageSize / 2.0
			v.width(Constants.avatarImageSize).height(Constants.avatarImageSize)
		}
		
		axis = .vertical
		alignment = .leading
		spacing = 10
		addArrangedSubview(titleLabel)
		addArrangedSubview(avatarImageView)
		addArrangedSubview(nameLabel)
	}
	
	private func attemptToLoadAvatarImage() {
		guard let url = author.avatar, let delegate = delegate else {
			return
		}
		let size = CGSize(
			width: Constants.avatarImageSize,
			height: Constants.avatarImageSize
		)
		delegate.loadImage(url: url, with: size)
			.then {[weak self] image in
				self?.avatarImageView.image = image
			}
	}
}
