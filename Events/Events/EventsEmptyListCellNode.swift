//
//  EventsEmptyListCellNode.swift
//  Events
//
//  Created by Dmitry on 27.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import AsyncDisplayKit

class EventsEmptyListCellNode: ASCellNode {
	weak var delegate: EventsEmptyListCellNodeDelegate?
	private let labelTextNode = ASTextNode()
	private let imageNode = ASImageNode()
	private let searchButton = ButtonNodeScaleOnPress()
	
	override init() {
		super.init()
		
		automaticallyManagesSubnodes = true
		setupLabel()
		imageNode.image = UIImage(named: "EmptyList")
		styleText(
			buttonNode: searchButton,
			text: NSLocalizedString(
				"Explore events",
				comment: "Event list empty: explore button"
			),
			size: 17,
			color: .blueButtonFont,
			style: .medium
		)
		
		searchButton.backgroundColor = .blueButtonBackground
		searchButton.cornerRoundingType = .defaultSlowCALayer
		searchButton.cornerRadius = 8
		searchButton.contentEdgeInsets = UIEdgeInsets(
      top: 8,
      left: 15,
      bottom: 8,
      right: 15
    )
	}
	
	override func didLoad() {
		searchButton.addTarget(
			self,
			action: #selector(onPressSearchButton),
			forControlEvents: .touchUpInside
		)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let size = UIScreen.main.bounds.width * 0.4
		imageNode.style.preferredSize = CGSize(
			width: size,
			height: size
		)
		let buttonSpec = ASInsetLayoutSpec(
			insets: UIEdgeInsets(top: 30, left: 30, bottom: 0, right: 30),
			child: searchButton
		)
		return ASStackLayoutSpec(
			direction: .vertical,
			spacing: 15,
			justifyContent: .center,
			alignItems: .center,
			children: [imageNode, labelTextNode, buttonSpec]
		)
	}
	
	private func setupLabel() {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		paragraphStyle.lineBreakMode = .byWordWrapping
		
		let text = NSLocalizedString(
			"You don't have upcoming events...",
			comment: "Event list empty label"
		)
		labelTextNode.isLayerBacked = false
		let textAttributes = [
			NSAttributedString.Key.font: FontStyle.bold.font(size: 22),
			NSAttributedString.Key.foregroundColor: UIColor.fontLabel,
			NSAttributedString.Key.paragraphStyle: paragraphStyle
		]
		labelTextNode.attributedText = NSAttributedString(string: text, attributes: textAttributes)
	}
	
	@objc private func onPressSearchButton() {
		delegate?.exploreEvents()
	}
}

protocol EventsEmptyListCellNodeDelegate: class {
	func exploreEvents()
}
