//
//  CreatedEventsViewModel.swift
//  Events
//
//  Created by Dmitry on 29.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxFlow
import RxCocoa
import RxSwift
import Promises

class CreatedEventsViewModel: Stepper, CreatedEventPresenter {
	let steps = PublishRelay<Step>()
  @FilteredList<Event>(keyPath: \.name) var events
  var isListLoaded: Bool = false
  weak var delegate: CreatedEventPresenterDelegate?
  private let disposeBag = DisposeBag()
  private let repository: CreatedEventsFirestoreRepository
  private weak var contextMenuViewController: EventViewController?
  
  init(repository: CreatedEventsFirestoreRepository) {
    self.repository = repository
  }
	
	@available(iOS 13.0, *)
	private lazy var contextMenuActions: [ContextMenuAction] = [
		ContextMenuAction(
      iconCode: Icon(material: "visibility", sfSymbol: "eye"),
      title: "View"
    ) {[weak self] index in
			self?.viewEvent(at: index)
		},
		ContextMenuAction(
      iconCode: Icon(material: "edit", sfSymbol: "pencil"),
      title: "Edit"
    ) {[weak self] index in
			guard let self = self else { return }
      self.editEvent(at: index)
		},
		ContextMenuAction(
			iconCode: Icon(material: "delete", sfSymbol: "trash"),
			title: "Delete",
			attributes: [.destructive]
		) {[weak self] index in
			self?.deleteEventFromContextMenu(at: index)
		}
	]
  
  func viewDidLoad() {
    repository.makeCreatedEventObservable()
      .subscribe(onNext: {[unowned self] (events: [Event]) in
        self.events = events
        self.isListLoaded = true
        self.delegate?.viewModelDidUpdateList(self)
      })
      .disposed(by: disposeBag)
  }
	
  func onClose() {
		steps.accept(EventStep.createdEventsDidComplete)
	}
	
  func editEvent(at index: Int) {
    let event = events[index]
		steps.accept(EventStep.editEvent(event: event))
	}
	
	func confirmEventDeletion(at index: Int, completion: @escaping (Bool) -> Void) {
		let submitAction = UIAlertAction(
			title: NSLocalizedString("Delete", comment: "Delete event"),
			style: .destructive,
			handler: {[weak self] _ in
				self?.removeEvent(at: index)
				completion(true)
			}
		)
		let cancelAction = UIAlertAction(
			title: NSLocalizedString("Cancel", comment: "Cancel alert"),
			style: .default,
			handler: { _ in completion(false) }
		)
		steps.accept(EventStep.alert(
			title: NSLocalizedString("Warning", comment: "Alert title: waring"),
			message: NSLocalizedString(
				"Are you sure that you want to delete event?",
				comment: "Delete event confirmation"
			),
			actions: [cancelAction, submitAction]
		))
	}
	
	func setSearchQuery(_ query: String) {
    let currentEvents = events
    _events.query = query
    let newEvents = events
    if currentEvents != newEvents {
      delegate?.viewModelDidUpdateList(self)
    }
	}
	
	func undoEventDeletion() {
    let event = _events.revertLastRemove()
    guard let removedEvent = event else { return }
    repository.undoEventDeletion(withId: removedEvent.id)
	}
	
	private func viewEvent(at index: Int) {
    steps.accept(EventStep.event(
      event: events[index],
      sharedImage: nil,
      sharedCardInfo: nil
    ))
	}
	
	private func deleteEventFromContextMenu(at index: Int) {
		confirmEventDeletion(at: index, completion: {[weak self] isSucceed in
			guard isSucceed, let self = self else { return }
			self.delegate?.viewModel(self, didRemoveCellAt: IndexPath(item: index, section: 0))
		})
	}
}

extension CreatedEventsViewModel {
	private func removeEvent(at index: Int) {
		let event = events[index]
    _events.remove(element: event)
    repository.removeEvent(withId: event.id)
	}
}

@available(iOS 13, *)
extension CreatedEventsViewModel {
	
	private struct ContextMenuAction {
		let iconCode: Icon
		let title: String
		let action: (Int) -> Void
		let attributes: UIMenuElement.Attributes
		
		init(
			iconCode: Icon,
			title: String,
			attributes: UIMenuElement.Attributes = [],
			action: @escaping (Int) -> Void
		) {
			self.iconCode = iconCode
			self.title = title
			self.action = action
			self.attributes = attributes
		}
	}

	func contextMenuConfigurationForEvent(at index: Int) -> UIContextMenuConfiguration? {
		let event = events[index]
		return UIContextMenuConfiguration(
			identifier: event.id as NSString,
			previewProvider: {[weak self] () -> UIViewController in
        let viewController = EventModuleConfigurator().configure(
          with: event,
          isInsideContextMenu: true
        )
				self?.contextMenuViewController = viewController
				return viewController
			},
			actionProvider: contextMenuActionsForEvent(at: index)
		)
	}
	
	func openEventFromContextMenu() {
		guard let viewController = contextMenuViewController else { return }
    let event = viewController.viewModel.event
		steps.accept(EventStep.event(event: event, sharedImage: nil, sharedCardInfo: nil))
	}
	
	private func contextMenuActionsForEvent(at index: Int) -> ([UIMenuElement]) -> UIMenu {
		return {[unowned self] (_ elements: [UIMenuElement]) -> UIMenu in
			let children = self.contextMenuActions.map { menuAction -> UIAction in
				return UIAction(
					title: menuAction.title,
					image: menuAction.iconCode.image(withSize: 30, andColor: .fontLabel),
					attributes: menuAction.attributes,
					handler: { _ in menuAction.action(index) }
				)
			}
			return UIMenu(title: "", options: [.destructive], children: children)
		}
	}
}

extension CreatedEventsViewModel {
  private struct RemovedEvent {
    let event: Event
    let position: Int
  }
}

protocol CreatedEventPresenter: Stepper {
  var events: [Event] { get }
  var isListLoaded: Bool { get set }
  var delegate: CreatedEventPresenterDelegate? { get set }
  
  func viewDidLoad()
  func onClose()
  func editEvent(at: Int)
  func setSearchQuery(_: String)
  func undoEventDeletion()
  func confirmEventDeletion(at: Int, completion: @escaping (Bool) -> Void)
  
  @available(iOS 13, *)
  func contextMenuConfigurationForEvent(at: Int) -> UIContextMenuConfiguration?
}

protocol CreatedEventPresenterDelegate: class {
  func viewModelDidUpdateList(_: CreatedEventPresenter)
  func viewModel(_: CreatedEventPresenter, didRemoveCellAt: IndexPath)
}
