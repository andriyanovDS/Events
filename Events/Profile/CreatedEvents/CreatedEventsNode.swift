//
//  CreatedEventsNode.swift
//  Events
//
//  Created by Dmitry on 29.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import AsyncDisplayKit

class CreatedEventNode: ASDisplayNode {
	let tableNode = ASTableNode()
	let searchTextField = ASEditableTextNode()
	let searchTextFieldBackgound = ASDisplayNode()
	let closeButton = ButtonNodeScaleOnPress()
	private let searchIcon = ASTextNode()
	
	override init() {
		super.init()
		setupNode()
	}
	
	override func didLoad() {
		super.didLoad()
		backgroundColor = .white
		tableNode.view.separatorStyle = .none
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let searchFieldWithIcon = ASStackLayoutSpec.horizontal()
		searchFieldWithIcon.alignItems = .center
		searchFieldWithIcon.children = [searchIcon, searchTextField]
		searchTextField.style.flexGrow = 1
		let searchFieldSpec = ASBackgroundLayoutSpec(
			child: ASInsetLayoutSpec(
				insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
				child: searchFieldWithIcon
			),
			background: searchTextFieldBackgound
		)
		let horizontalSpec = ASStackLayoutSpec(
			direction: .horizontal,
			spacing: 8,
			justifyContent: .start,
			alignItems: .center,
			children: [searchFieldSpec, closeButton]
		)
		searchFieldSpec.style.flexGrow = 1
		let insetSpec = ASInsetLayoutSpec(
			insets: UIEdgeInsets(top: safeAreaInsets.top + 5.0, left: 10, bottom: 10, right: 10),
			child: horizontalSpec
		)
		let verticalStack = ASStackLayoutSpec.vertical()
		verticalStack.children = [insetSpec, tableNode]
		tableNode.style.flexGrow = 1
		return verticalStack
	}
	
	private func setupNode() {
		automaticallyManagesSubnodes = true
		automaticallyRelayoutOnSafeAreaChanges = true
		setStyledText(
			editableTextNode: searchTextField,
			text: "",
			placeholderText: NSLocalizedString(
				"Enter event name",
				comment: "Created events: search text field placeholder"
			),
			size: 16,
			style: .medium
		)
		searchTextField.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
		searchTextFieldBackgound.backgroundColor = .gray100()
		searchTextFieldBackgound.cornerRadius = 15
		searchTextFieldBackgound.cornerRoundingType = .defaultSlowCALayer
		styleText(
			buttonNode: closeButton,
			text: NSLocalizedString(
				"Cancel",
				comment: "Created events: cancel button label"
			),
			size: 16,
			color: .black,
			style: .medium
		)
		searchIcon.attributedText = NSAttributedString(
			string: String.fontMaterialIcon("search")!,
			attributes: [
				NSAttributedString.Key.font: UIFont.icon(from: .materialIcon, ofSize: 26.0),
				NSAttributedString.Key.foregroundColor: UIColor.black
			])
	}
}
