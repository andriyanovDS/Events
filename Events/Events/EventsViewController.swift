//
//  EventsViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 09/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class EventsViewController: ASViewController<EventsNode>, ViewModelBased {
	var viewModel: EventsViewModel!
	
	init() {
		super.init(node: EventsNode())
		node.collectionNode.delegate = self
		node.collectionNode.dataSource = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	struct Constants {
		static let columnsCount: Int = 2
	}
	
  override func viewDidLoad() {
    super.viewDidLoad()
		viewModel.delegate = self
  }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		viewModel.loadList()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		viewModel.clearEvents()
		node.collectionNode.reloadData()
	}
}

extension EventsViewController: ASCollectionDataSource {
	
	func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
		return max(
			1,
			Int(ceil(Float(viewModel.events.count) / Float(Constants.columnsCount)))
		)
	}
	
	func collectionNode(
		_ collectionNode: ASCollectionNode,
		numberOfItemsInSection section: Int
	) -> Int {
		if viewModel.events.isEmpty { return 1 }
		let restItemsCount = viewModel.events.count - section * Constants.columnsCount
		return restItemsCount >= Constants.columnsCount
			? Constants.columnsCount
			: restItemsCount
	}
	
	func collectionNode(
		_ collectionNode: ASCollectionNode,
		nodeBlockForItemAt indexPath: IndexPath
	) -> ASCellNodeBlock {
		if viewModel.isLoadedListEmpty {
			return {[weak self] in
				let cell = EventsEmptyListCellNode()
				cell.delegate = self?.viewModel
				cell.style.height = ASDimension(
					unit: .points,
					value: UIScreen.main.bounds.height * 0.7
				)
				return cell
			}
		}
		if viewModel.events.isEmpty { return { ASCellNode() } }
		let index = indexPath.section * Constants.columnsCount + indexPath.item
		let event = viewModel.events[index]
		return {
			let cell = UserEventCellNode(event: event)
			cell.style.width = ASDimension(
				unit: .points,
				value: UserEventCellNode.Constants.cellWidth
			)
			return cell
		}
	}
	
	func collectionNode(
		_ collectionNode: ASCollectionNode,
		nodeForSupplementaryElementOfKind kind: String,
		at indexPath: IndexPath
	) -> ASCellNode {
		if indexPath.section == 0 && kind == UICollectionView.elementKindSectionHeader {
			return SectionHeaderCellNode()
		}
		return ASCellNode()
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
		let cellOption = collectionNode.nodeForItem(at: indexPath) as? UserEventCellNode
		guard let cell = cellOption else { return }
		viewModel.openEvent(cell.event, sharedImage: cell.eventImageNode.image)
	}
}

extension EventsViewController: ASCollectionDelegateFlowLayout {
	
	func collectionNode(
		_ collectionNode: ASCollectionNode,
		sizeRangeForHeaderInSection section: Int
	) -> ASSizeRange {
		return ASSizeRangeUnconstrained
	}
}

extension EventsViewController: EventsViewModelDelegate {
	
	func listDidUpdated() {
		node.collectionNode.reloadData()
	}
}
