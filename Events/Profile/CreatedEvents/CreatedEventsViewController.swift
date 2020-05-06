//
//  CreatedEventsViewController.swift
//  Events
//
//  Created by Dmitry on 29.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import AsyncDisplayKit

class CreatedEventsViewController: ASViewController<CreatedEventNode>, ViewModelBased {
	var viewModel: CreatedEventPresenter!
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
    viewModel.delegate = self
    viewModel.viewDidLoad()
		
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
			self,
			action: #selector(handleCloseButtonPress),
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
  
  @objc func handleCloseButtonPress() {
    viewModel.onClose()
  }
}

extension CreatedEventsViewController {
  func removeCellWithUndoAction(at indexPath: IndexPath) {
    node.showUndoAction()
    if let currentTask = undoEventDeletionTask {
      currentTask.cancel()
      undoEventDeletionTask = nil
    }
    let task = DispatchWorkItem {[weak self] in
      self?.node.hideUndoAction()
      self?.undoEventDeletionTask = nil
    }
    undoEventDeletionTask = task
    DispatchQueue.main.asyncAfter(
      deadline: DispatchTime.now() + .seconds(Constants.undoActionTimeoutInSeconds),
      execute: task
    )
    node.tableNode.performBatchUpdates({
      self.node.tableNode.deleteRows(at: [indexPath], with: .left)
    }, completion: nil)
  }
}

extension CreatedEventsViewController: CreatedEventPresenterDelegate {
  
  func viewModel(_: CreatedEventPresenter, didRemoveCellAt indexPath: IndexPath) {
    removeCellWithUndoAction(at: indexPath)
  }
  
  func viewModelDidUpdateList(_: CreatedEventPresenter) {
    node.hideLoadingNode()
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
				self.viewModel.confirmEventDeletion(
					at: indexPath.item,
					completion: { isSucceed in
						if isSucceed { self.removeCellWithUndoAction(at: indexPath) }
						completionHandler(isSucceed)
					}
				)
			}
		)
    action.setIcon(
      Icon(material: "delete", sfSymbol: "trash"),
      size: 25,
      color: .fontLabelInverted
    )
		action.backgroundColor = .destructive
		let configuration = UISwipeActionsConfiguration(actions: [action])
		return configuration
	}
	
	func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    viewModel.editEvent(at: indexPath.item)
	}
	
	@available(iOS 13, *)
	func tableView(
		_ tableView: UITableView,
		contextMenuConfigurationForRowAt indexPath: IndexPath,
		point: CGPoint
	) -> UIContextMenuConfiguration? {
		return viewModel.contextMenuConfigurationForEvent(at: indexPath.item)
	}
}

extension CreatedEventsViewController: ASEditableTextNodeDelegate {
	func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
		viewModel.setSearchQuery(editableTextNode.attributedText?.string ?? "")
	}
}
