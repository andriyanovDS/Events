//
//  EventsNode.swift
//  Events
//
//  Created by Dmitry on 26.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class EventsNode: ASDisplayNode {
	let collectionNode: ASCollectionNode
	
	override init() {
		let flowLayout = EventsCollectionNodeFlowLayout()
		collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
		
		super.init()
		automaticallyManagesSubnodes = true
		collectionNode.registerSupplementaryNode(ofKind: UICollectionView.elementKindSectionHeader)
		flowLayout.minimumInteritemSpacing = 10
		flowLayout.minimumLineSpacing = 10
		collectionNode.contentInset = UIEdgeInsets(
			top: 50,
			left: 10,
			bottom: 30,
			right: 10
		)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		return ASWrapperLayoutSpec(layoutElement: collectionNode)
	}
}
