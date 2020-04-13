//
//  EventFooterView.swift
//  Events
//
//  Created by Dmitry on 25.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class EventFooterView: UIView {
	let joinEventButton = ButtonScale()
	var joinButtonState: JoinButtonState {
		didSet {
			joinButtonStateDidChange()
		}
	}
	private let priceLabel = UILabel()
	private let pricePerPerson: Float?
	lazy var activityIndicatorView: UIView = {
		let activityIndicatorView = UIView()
		activityIndicatorView.backgroundColor = UIColor.background.withAlphaComponent(0.6)
    let activityIndicator = UIActivityIndicatorView.init(style: .gray)
    activityIndicator.startAnimating()
    activityIndicatorView.sv(activityIndicator)
		activityIndicator.centerInContainer()
    return activityIndicatorView
  }()
	
	init(pricePerPerson: Float?) {
		self.pricePerPerson = pricePerPerson
		joinButtonState = .joinInProgress
		super.init(frame: CGRect.zero)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	enum JoinButtonState {
		case notJoined, joinInProgress, joined
		
		var labelText: String {
			switch self {
			case .joined:
				return NSLocalizedString("Cancel join", comment: "Cancel event button label")
			case .notJoined:
				return NSLocalizedString("Join", comment: "Join event button label")
			default:
				return ""
			}
		}
		
		var backgroundColor: UIColor {
			switch self {
			case .joined:
			return .destructive
			case .notJoined:
			return .blueButtonBackground
			default:
			return .clear
			}
		}
	}
	
	private func setupView() {
		backgroundColor = .background
		styleText(
			label: priceLabel,
			text: pricePerPerson
				.map { v in "\(v) рублей" }
				.getOrElse(result: "Бесплатно"),
			size: 18,
			color: .fontLabel,
			style: .medium
		)
		styleText(
			button: joinEventButton,
			text: joinButtonState.labelText,
			size: 16,
			color: .blueButtonFont,
			style: .medium
		)
		joinEventButton.backgroundColor = joinButtonState.backgroundColor
		sv([joinEventButton, priceLabel])
		let buttonBottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
		joinEventButton.right(20).top(15).bottom(5 + buttonBottomPadding).width(150)
		priceLabel.left(20).CenterY == joinEventButton.CenterY
		priceLabel.Right == joinEventButton.Left - 10
	}
	
	private func joinButtonStateDidChange() {
		switch joinButtonState {
		case .joinInProgress:
			joinEventButton.sv(activityIndicatorView)
			activityIndicatorView.fillContainer().centerInContainer()
			return
		case .notJoined, .joined:
			activityIndicatorView.removeFromSuperview()
			joinEventButton.backgroundColor = joinButtonState.backgroundColor
			joinEventButton.setTitle(
				joinButtonState.labelText,
				for: .normal
			)
			return
		}
	}
}
