//
//  UserEventCellNode.swift
//  Events
//
//  Created by Dmitry on 26.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import AsyncDisplayKit

class UserEventCellNode: ASCellNode {
	let event: Event
	let eventImageNode = ASImageNode()
	private let dateTextNode = ASTextNode()
	private let eventNameTextNode = ASTextNode()
	
	struct Constants {
		static let cellWidth =
			UIScreen.main.bounds.width / CGFloat(EventsViewController.Constants.columnsCount) - 15
		static let imageHeight: CGFloat = Constants.cellWidth * 0.7
	}
	
	init(event: Event) {
		self.event = event
		
		super.init()
		
		alpha = 0
		automaticallyManagesSubnodes = true
		eventImageNode.cornerRoundingType = .defaultSlowCALayer
		eventImageNode.cornerRadius = 10
		eventImageNode.clipsToBounds = true
		eventImageNode.backgroundColor = .gray100()
		eventImageNode.contentMode = .scaleAspectFill
		eventNameTextNode.maximumNumberOfLines = 4
	
		styleLayerBackedText(
			textNode: dateTextNode,
			text: event.dateLabelText,
			size: 12,
			color: .black,
			style: .medium
		)
		styleLayerBackedText(
			textNode: eventNameTextNode,
			text: event.name,
			size: 16,
			color: .black,
			style: .bold
		)
	}
	
	override func didLoad() {
		super.didLoad()
		backgroundColor = .white
		eventImageNode.view.hero.id = event.id
		if let url = event.mainImageUrl {
			eventImageNode.loadImageFromExternalUrl(
				url,
				withResizeTo: CGSize(
					width: Constants.cellWidth,
					height: Constants.imageHeight
				),
				transitionConfig: UIImageView.TransitionConfig(duration: 0.4)
			)
		}
	}
	
	override func didEnterVisibleState() {
		UIView.animate(withDuration: 0.2, animations: {
			self.view.alpha = 1
		})
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let textContentStack = ASStackLayoutSpec(
			direction: .vertical,
			spacing: 6,
			justifyContent: .start,
			alignItems: .start,
			children: [dateTextNode, eventNameTextNode]
		)
		let textContentInsetStack = ASInsetLayoutSpec(
			insets: UIEdgeInsets(top: 0, left: 10, bottom: 15, right: 10),
			child: textContentStack
		)
		eventImageNode.style.preferredSize = CGSize(
			width: Constants.cellWidth,
			height: Constants.imageHeight
		)
		return ASStackLayoutSpec(
			direction: .vertical,
			spacing: 10,
			justifyContent: .start,
			alignItems: .start,
			children: [eventImageNode, textContentInsetStack]
		)
	}
}
