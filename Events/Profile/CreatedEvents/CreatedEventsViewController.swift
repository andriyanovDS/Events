//
//  CreatedEventsViewController.swift
//  Events
//
//  Created by Dmitry on 29.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import AsyncDisplayKit

class CreatedEventsViewController: ASViewController<CreatedEventNode>, ViewModelBased {
	var viewModel: CreatedEventsViewModel! {
		didSet { viewModel.delegate = self }
	}
	private var undoEventDeletionTask: DispatchWorkItem?

	init() {
		super.init(node: CreatedEventNode())
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	struct Constants {
		static let undoActionTimeoutInSeconds: Int = 5
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		node.searchTextField.delegate = self
		node.tableNode.dataSource = self
		node.tableNode.delegate = self
		node.searchTextField.becomeFirstResponder()
		node.undoActionNode.undoButtonNode.addTarget(
			self,
			action: #selector(undoEventDeletion),
			forControlEvents: .touchUpInside
		)
		node.closeButton.addTarget(
			viewModel,
			action: #selector(viewModel.closeScreen),
			forControlEvents: .touchUpInside
		)
	}
	
	@objc private func undoEventDeletion() {
		if let task = undoEventDeletionTask {
			task.cancel()
			undoEventDeletionTask = nil
		}
		viewModel.undoEventDeletion()
		node.hideUndoAction()
	}
}

extension CreatedEventsViewController: CreatedEventsViewModelDelegate {
	
	func listDidUpdate() {
		node.tableNode.reloadData()
	}
}

extension CreatedEventsViewController: ASTableDataSource {
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		viewModel.events.count
	}
	
	func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
		let event = viewModel.events[indexPath.item]
		
		return {
			let cell = CreatedEventCellNode(event: event)
			cell.style.width = ASDimension(unit: .fraction, value: 1)
			return cell
		}
	}
}

extension CreatedEventsViewController: ASTableDelegate, UITableViewDelegate {
	private func removeEvent(at indexPath: IndexPath) {
		node.showUndoAction()
		undoEventDeletionTask = DispatchWorkItem {[weak self] in
			self?.node.hideUndoAction()
			self?.undoEventDeletionTask = nil
		}
		DispatchQueue.main.asyncAfter(
			deadline: DispatchTime.now() + .seconds(Constants.undoActionTimeoutInSeconds),
			execute: undoEventDeletionTask!
		)
		node.tableNode.performBatchUpdates({
			self.node.tableNode.deleteRows(at: [indexPath], with: .left)
		}, completion: nil)
	}
	
	func tableView(
		_ tableView: UITableView,
		trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
	) -> UISwipeActionsConfiguration? {
		
		let action = UIContextualAction(
			style: .normal,
			title: "",
			handler: {[weak self] (_, _, completionHandler) in
				guard let self = self else {
					completionHandler(false)
					return
				}
				self.viewModel.confirmEventDelete(
					at: indexPath.item,
					completionHandler: { isSucceed in
						if isSucceed { self.removeEvent(at: indexPath) }
						completionHandler(isSucceed)
					}
				)
			}
		)

		action.image = UIImage(
			from: .materialIcon,
			code: "delete",
			textColor: .white,
			backgroundColor: .clear,
			size: CGSize(width: 35, height: 35)
		)
		action.backgroundColor = .lightRed()
		let configuration = UISwipeActionsConfiguration(actions: [action])
		return configuration
	}
}

extension CreatedEventsViewController: ASEditableTextNodeDelegate {
	func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
		viewModel.filterEvents(
			whereEventName: editableTextNode.attributedText?.string ?? ""
		)
	}
}
