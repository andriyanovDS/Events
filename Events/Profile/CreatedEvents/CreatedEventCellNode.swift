//
//  CreatedEventCellNode.swift
//  Events
//
//  Created by Dmitry on 29.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import AsyncDisplayKit

class CreatedEventCellNode: ASCellNode {
	let event: Event
	private let eventImageNode = ASImageNode()
	private let eventNameTextNode = ASTextNode()
	private let eventDateTextNode = ASTextNode()
	
	init(event: Event) {
		self.event = event
		super.init()
		setupNode()
	}
	
	struct Constants {
		static let imageSize = CGSize(
			width: UIScreen.main.bounds.width * 0.14,
			height: UIScreen.main.bounds.width * 0.14
		)
	}
	
	override func didEnterDisplayState() {
		guard let url = event.mainImageUrl else { return }
		let scale = UIScreen.main.scale
		let transform = CGAffineTransform(scaleX: scale, y: scale)
		eventImageNode.loadImageFromExternalUrl(
			url,
			withResizeTo: Constants.imageSize.applying(transform)
		)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let textSpec = ASStackLayoutSpec.vertical()
		textSpec.spacing = 5
		textSpec.children = [eventNameTextNode, eventDateTextNode]
		let textInsetSpec = ASInsetLayoutSpec(
			insets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10),
			child: textSpec
		)
		textInsetSpec.style.flexShrink = 1
		eventImageNode.style.preferredSize = Constants.imageSize
		let mainSpec = ASStackLayoutSpec.horizontal()
		mainSpec.alignItems = .center
		mainSpec.children = [eventImageNode, textInsetSpec]
		return ASInsetLayoutSpec(
			insets: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10),
			child: mainSpec
		)
	}
	
	private func setupNode() {
		automaticallyManagesSubnodes = true
		backgroundColor = .background
		eventImageNode.backgroundColor = .background
		eventImageNode.cornerRadius = Constants.imageSize.width / 2.0
		eventImageNode.cornerRoundingType = .precomposited
		
		styleLayerBackedText(
			textNode: eventNameTextNode,
			text: event.name,
			size: 18,
			color: .fontLabel,
			style: .bold
		)
		eventNameTextNode.maximumNumberOfLines = 3
		styleLayerBackedText(
			textNode: eventDateTextNode,
			text: event.dateLabelText,
			size: 15,
			color: .fontLabelDescription,
			style: .medium
		)
	}
}
