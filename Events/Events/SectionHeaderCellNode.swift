//
//  SectionHeaderCellNode.swift
//  Events
//
//  Created by Dmitry on 26.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import AsyncDisplayKit

class SectionHeaderCellNode: ASCellNode {
	private let titleTextNode = ASTextNode()
	
	override init() {
		super.init()
		
		styleLayerBackedText(
			textNode: titleTextNode,
			text: NSLocalizedString("Events", comment: "User events list: title"),
			size: 24,
			color: .black,
			style: .bold
		)
		addSubnode(titleTextNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		return ASInsetLayoutSpec(
			insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
			child: titleTextNode
		)
	}
}
