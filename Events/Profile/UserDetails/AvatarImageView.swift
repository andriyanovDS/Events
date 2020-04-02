//
//  AvatarImageView.swift
//  Events
//
//  Created by Dmitry on 03.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class AvatarImageView: UIImageView {
	
	override var image: UIImage? {
		didSet {
			contentMode = .scaleAspectFill
		}
	}
	
	init(defaultImage: UIImage) {
		super.init(frame: CGRect.zero)
		image = defaultImage
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
