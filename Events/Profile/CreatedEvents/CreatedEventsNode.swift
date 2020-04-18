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
	let searchTextFieldBackground = ASDisplayNode()
	let closeButton = ButtonNodeScaleOnPress()
	var undoActionNode = UndoActionNode()
	private var isLoadingInProgress: Bool = true
	private let loadingNode: ASDisplayNode
	private let searchIconImageNode = ASImageNode()
	private var isUndoActionRequired: Bool = false {
		didSet {
			undoActionNode.isUserInteractionEnabled = isUndoActionRequired
		}
	}
	
	override init() {
		loadingNode = ASDisplayNode(viewBlock: { LoadingView() })
		super.init()
		setupNode()
	}
	
	override func didLoad() {
		super.didLoad()
		backgroundColor = .background
		tableNode.view.separatorStyle = .none
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let searchFieldWithIcon = ASStackLayoutSpec.horizontal()
		searchFieldWithIcon.alignItems = .center
    searchIconImageNode.style.preferredSize = CGSize(width: 26, height: 26)
		searchFieldWithIcon.children = [searchIconImageNode, searchTextField]
		searchTextField.style.flexGrow = 1
		let searchFieldSpec = ASBackgroundLayoutSpec(
			child: ASInsetLayoutSpec(
				insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
				child: searchFieldWithIcon
			),
			background: searchTextFieldBackground
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
		
		let tableSpec = tableLayoutSpec()
		let verticalStack = ASStackLayoutSpec.vertical()
		verticalStack.children = [insetSpec, tableSpec]
		
		if isUndoActionRequired {
			let undoSpec = ASInsetLayoutSpec(
				insets: UIEdgeInsets(top: CGFloat.infinity, left: 20, bottom: 40, right: 20),
				child: undoActionNode
			)
			return ASOverlayLayoutSpec(child: verticalStack, overlay: undoSpec)
		}
		return verticalStack
	}
	
	override func animateLayoutTransition(_ context: ASContextTransitioning) {
		if isUndoActionRequired {
			let finalUndoFrame = context.finalFrame(for: undoActionNode)
			
			undoActionNode.frame = CGRect(
				x: finalUndoFrame.minX,
				y: finalUndoFrame.minY + 100.0,
				width: finalUndoFrame.width,
				height: finalUndoFrame.height
			)
			undoActionNode.alpha = 0

			UIView.animate(withDuration: 0.4, animations: {
				self.undoActionNode.frame = finalUndoFrame
				self.undoActionNode.alpha = 1
			}, completion: { finished in
				context.completeTransition(finished)
			})
		} else {
			let initialUndoFrame = context.initialFrame(for: undoActionNode)

			UIView.animate(withDuration: 0.4, animations: {
				self.undoActionNode.frame = CGRect(
					x: initialUndoFrame.minX,
					y: initialUndoFrame.minY + 100.0,
					width: initialUndoFrame.width,
					height: initialUndoFrame.height
				)
				self.undoActionNode.alpha = 0
			}, completion: { finished in
				context.completeTransition(finished)
			})
		}
	}
	
	func hideLoadingNode() {
		guard isLoadingInProgress else { return }
		isLoadingInProgress = false
		setNeedsLayout()
	}
	
	func showUndoAction() {
		guard !isUndoActionRequired else { return }
		isUndoActionRequired = true
		transitionLayout(withAnimation: true, shouldMeasureAsync: false)
	}
	
	func hideUndoAction() {
		guard isUndoActionRequired else { return }
		isUndoActionRequired = false
		transitionLayout(withAnimation: true, shouldMeasureAsync: false)
	}
	
	private func tableLayoutSpec() -> ASLayoutSpec {
		if isLoadingInProgress {
			let loadingNodeSpec = ASInsetLayoutSpec(
				insets: UIEdgeInsets(
					top: 40,
					left: CGFloat.infinity,
					bottom: CGFloat.infinity,
					right: CGFloat.infinity
				),
				child: loadingNode
			)
			let overlaySpec = ASOverlayLayoutSpec(child: tableNode, overlay: loadingNodeSpec)
			overlaySpec.style.flexGrow = 1
			return overlaySpec
		}
		let wrapperSpec = ASWrapperLayoutSpec(layoutElement: tableNode)
		wrapperSpec.style.flexGrow = 1
		return wrapperSpec
	}
	
	private func setupNode() {
		automaticallyManagesSubnodes = true
		automaticallyRelayoutOnSafeAreaChanges = true
		loadingNode.isUserInteractionEnabled = false
		undoActionNode.isUserInteractionEnabled = false
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
		searchTextFieldBackground.backgroundColor = .textField
		searchTextFieldBackground.cornerRadius = 15
		searchTextFieldBackground.cornerRoundingType = .defaultSlowCALayer
		styleText(
			buttonNode: closeButton,
			text: NSLocalizedString(
				"Cancel",
				comment: "Created events: cancel button label"
			),
			size: 16,
			color: .fontLabel,
			style: .medium
		)
    searchIconImageNode.contentMode = .center
   
    searchIconImageNode.image = Icon(material: "search", sfSymbol: "magnifyingglass")
      .image(withSize: 26, andColor: .fontLabel)
	}
}
