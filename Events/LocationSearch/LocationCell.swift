//
//  LocationItem.swift
//  Events
//
//  Created by Дмитрий Андриянов on 14/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import SwiftIconFont

class LocationCell: UITableViewCell {
	var prediction: Prediction? {
		didSet {
			nameLabel.text = prediction?.description
		}
	}
	private let nameLabel = UILabel()
	private let iconLabel = UILabel()
	
	static let reuseIdentifier = String(describing: LocationCell.self)
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(
			style: .default,
			reuseIdentifier: String(describing: LocationCell.reuseIdentifier)
		)
    setupView()
		setupConstraints()
	}

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
	
	override func prepareForReuse() {
		nameLabel.text = ""
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		if selected {
			contentView.backgroundColor = .selectionGray
			contentView.layer.cornerRadius = 15
		} else {
			contentView.backgroundColor = .background
			contentView.layer.cornerRadius = 0
		}
	}

  private func setupView() {
		backgroundColor = .clear
		selectionStyle = .none
		iconLabel.font = UIFont.icon(from: .materialIcon, ofSize: 30.0)
		iconLabel.text = String.fontMaterialIcon("location.on")
		iconLabel.textColor = .fontLabel
		
		styleText(
			label: nameLabel,
			text: "",
			size: 18,
			color: .fontLabel,
			style: .medium
		)
		nameLabel.textAlignment = .left
		nameLabel.numberOfLines = 2
		sv(iconLabel, nameLabel)
  }

	private func setupConstraints() {
		iconLabel.left(0).top(10).bottom(10).width(30)
		nameLabel.right(0).CenterY == iconLabel.CenterY
		nameLabel.Left == iconLabel.Right + 10
	}
}
