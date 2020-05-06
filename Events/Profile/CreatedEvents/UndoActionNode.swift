//
//  UndoActionNode.swift
//  Events
//
//  Created by Dmitry on 31.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import AsyncDisplayKit

class UndoActionNode: ASDisplayNode {
	let undoButtonNode = ButtonNodeScaleOnPress()
	private let descriptionTextNode = ASTextNode()
	private let counterNode: ASDisplayNode
	
	override init() {
		counterNode = ASDisplayNode(viewBlock: { UndoActionCounterView() })
		super.init()
		setupNode()
	}
  
  func restartAction() {
    guard let counterView = counterNode.view as? UndoActionCounterView else {
      return
    }
    counterView.restartTimer()
  }
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		counterNode.style.preferredSize = CGSize(
			width: 30,
			height: 30
		)
		let verticalSpec = ASStackLayoutSpec(
			direction: .horizontal,
			spacing: 10,
			justifyContent: .spaceBetween,
			alignItems: .center,
			children: [counterNode, descriptionTextNode, undoButtonNode]
		)
		return ASInsetLayoutSpec(
			insets: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10),
			child: verticalSpec
		)
	}
	
	private func setupNode() {
		automaticallyManagesSubnodes = true
		backgroundColor = UIColor.backgroundInverted.withAlphaComponent(0.6)
		cornerRadius = 10
		cornerRoundingType = .defaultSlowCALayer
		styleLayerBackedText(
			textNode: descriptionTextNode,
			text: NSLocalizedString("Event deleted", comment: "Action description: Event deleted"),
			size: 16,
			color: .fontLabelInverted,
			style: .medium
		)
		styleText(
			buttonNode: undoButtonNode,
			text: NSLocalizedString("Undo", comment: "Undo action"),
			size: 17,
      color: UIColor.valueButton.withAlphaComponent(0.7),
			style: .medium
		)
	}
}
