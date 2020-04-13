//
//  EventNode.swift
//  Events
//
//  Created by Дмитрий Андриянов on 22/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import Hero
import Promises
import AVFoundation

class EventView: UIView {
  weak var dataSource: EventNodeDataSource?
  let closeButtonView = UIButtonScaleOnPress()
	let followButtonView = UIButtonScaleOnPress()
  let eventImageView = UIImageView()
	let scrollView = UIScrollView()
	let footerView: EventFooterView
	let loadImageQueue = DispatchQueue(
    label: "com.event.eventImageLoad",
		qos: .default,
    attributes: [.concurrent],
    autoreleaseFrequency: .inherit,
    target: nil
  )
	let loadImageSemaphore = DispatchSemaphore(value: 3)
	private let contentView = UIView()
	private let actionsStackView = UIStackView()
	private let actionsBackgroundView = UIView()
  private let infoBackgroundView = UIView()
  private let categoryNameLabel = UILabel()
  private let eventNameLabel = UILabel()
  private let locationNameLabel = UILabel()
  private let separatorView = UIView()
	private let infoStackView = UIStackView()
  private let infoSections: [EventInfoSection]
	private let descriptionsStackView = UIStackView()
  private let descriptionViews: [EventDescriptionView]
	private let animator = UIViewPropertyAnimator(duration: 1.0, curve: .linear)
  private var imageSize: CGSize = CGSize(
		width: UIScreen.main.bounds.width,
		height: Constants.eventImageHeight
	)
	private var safeAreaTopPadding: CGFloat {
		UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
	}
	private lazy var locationView: EventLocationView = {
		let location = dataSource!.event.location
		return EventLocationView(location: location)
	}()

  init(sharedImage: UIImage?, dataSource: EventNodeDataSource) {
    self.dataSource = dataSource
    infoSections = [
      EventInfoSection(
        title: NSLocalizedString("When", comment: "Event info section title: date"),
        iconCode: "today",
        value: dataSource.event.dateLabelText
      ),
      EventInfoSection(
        title: NSLocalizedString("Duration", comment: "Event info section title: time"),
        iconCode: "schedule",
        value: dataSource.event.duration.localizedLabel
      )
    ]
		footerView = EventFooterView(pricePerPerson: nil)
    descriptionViews = dataSource.event.description.map { EventDescriptionView(description: $0) }
    super.init(frame: CGRect.zero)
		scrollView.delegate = self
    descriptionViews.forEach { $0.delegate = self }
    setupView(sharedImage: sharedImage)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
	
	deinit {
		animator.stopAnimation(false)
		if animator.state == .stopped {
			animator.finishAnimation(at: .current)
		}
	}

  struct Constants {
		static let actionsStackHeight: CGFloat = 60.0
		static let actionStackAnimationDelayFactor: CGFloat =
			1 - Constants.actionsStackHeight / Constants.eventImageHeight
    static let eventImageHeight: CGFloat = UIScreen.main.bounds.height * 0.3
  }

  private func setupView(sharedImage: UIImage?) {
		backgroundColor = .background
		isOpaque = false
		layer.cornerRadius = 15
		clipsToBounds = true
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
    infoBackgroundView.backgroundColor = .backgroundInverted
		actionsBackgroundView.backgroundColor = .clear
    eventImageView.image = sharedImage
		separatorView.backgroundColor = .fontLabelInverted
		eventImageView.contentMode = .scaleAspectFill
    
		setupAnimations()
		setupInfoStackView()
		setupDescriptionsStackView()
		setupAuthorView()
		
    sv([
			scrollView.sv(
				contentView.sv([
					eventImageView,
					infoBackgroundView.sv(infoStackView),
					descriptionsStackView
				])
			)
		])
    setupConstraints()
		
		if let dataSource = dataSource, !dataSource.isInsideContextMenu {
			setupActions()
			descriptionsStackView.addArrangedSubview(locationView)
		}

    descriptionViews
      .filter { !$0.eventDescription.isMain }
      .enumerated()
      .forEach { (index, view) in
        view.titleButton.uniqueData = index
        view.titleButton.addTarget(
          self,
          action: #selector(onPressDescriptionTitle(_:)),
          for: .touchUpInside
        )
      }
    if let url = dataSource?.event.mainImageUrl {
      loadEventImage(url: url)
    }
  }
	
	private func setupActions() {
		setupActionButtons()
		setupActionsStackView()
		sv([
			actionsBackgroundView,
			actionsStackView,
			footerView
		])
		setupActionsConstraints()
	}
	
	private func setupAnimations() {
		animator.addAnimations({[unowned self] in
			self.actionsBackgroundView.backgroundColor = .background
		}, delayFactor: Constants.actionStackAnimationDelayFactor)
	}
	
	private func setupActionsStackView() {
		actionsStackView.axis = .horizontal
		actionsStackView.alignment = .center
		actionsStackView.distribution = .equalSpacing
		actionsStackView.isLayoutMarginsRelativeArrangement = true
		actionsStackView.layoutMargins = UIEdgeInsets(
			top: safeAreaTopPadding + 10,
			left: 20,
			bottom: 0,
			right: 20
		)
		closeButtonView.width(40).height(40)
		followButtonView.width(40).height(40)
		actionsStackView.addArrangedSubview(followButtonView)
		actionsStackView.addArrangedSubview(closeButtonView)
	}
	
	private func setupInfoStackView() {
		setupInfo()
		infoStackView.axis = .vertical
		infoStackView.spacing = 8
		infoStackView.addArrangedSubview(categoryNameLabel)
		infoStackView.addArrangedSubview(eventNameLabel)
		infoStackView.addArrangedSubview(locationNameLabel)
		infoStackView.addArrangedSubview(separatorView)
		
		infoSections
			.chunks(2)
			.map { sections in
				let stackView = UIStackView()
				stackView.axis = .horizontal
				stackView.distribution = .fillEqually
				sections.forEach { stackView.addArrangedSubview($0) }
				return stackView
			}
			.forEach { v in infoStackView.addArrangedSubview(v) }
	}
	
	private func setupDescriptionsStackView() {
		descriptionsStackView.axis = .vertical
		descriptionsStackView.spacing = 15
		descriptionViews.forEach { descriptionsStackView.addArrangedSubview($0) }
	}
	
	private func setupAuthorView() {
		guard let author = dataSource?.author else { return }
		let view = EventAuthorView(author: author)
		view.delegate = self
		descriptionsStackView.addArrangedSubview(view)
	}
	
	private func setupActionsConstraints() {
		actionsStackView
			.top(-safeAreaTopPadding)
			.left(0)
			.right(0)
			.height(Constants.actionsStackHeight)
		actionsBackgroundView.Top == actionsStackView.Top
		actionsBackgroundView.Bottom == actionsStackView.Bottom
		actionsBackgroundView.left(0).right(0)
		footerView.left(0).right(0).bottom(0)
	}

  private func setupConstraints() {
		scrollView
			.top(0)
		  .left(0)
			.right(0)
			.bottom(0)
			.Width == Width
		contentView.fillContainer().width(100%)
    eventImageView
      .top(0)
      .left(0)
      .width(UIScreen.main.bounds.width)
      .height(Constants.eventImageHeight)
		
		separatorView.translatesAutoresizingMaskIntoConstraints = false
    separatorView.left(10).right(10).height(2)
		infoBackgroundView.left(0).right(0).Top == eventImageView.Bottom
		infoStackView.left(20).right(20).top(10).bottom(15)
		descriptionsStackView.Top == infoBackgroundView.Bottom + 15
		descriptionsStackView.left(20).right(20).bottom(60)
  }

  @objc private func onPressDescriptionTitle(_ sender: ButtonNodeScaleOnPress) {
    guard let index = sender.uniqueData as? Int else { return }
    let descriptionView = descriptionViews[index + 1]
    descriptionView.isExpanded = !descriptionView.isExpanded
  }

  private func setupInfo() {
    guard let event = dataSource?.event else { return }
    styleText(
      label: categoryNameLabel,
      text: event.categories
        .map { $0.translatedLabel() }
        .joined(separator: ", "),
      size: 16,
      color: .fontLabelInverted,
      style: .medium
    )
    styleText(
      label: eventNameLabel,
      text: event.name,
      size: 24,
      color: .fontLabelInverted,
      style: .bold
    )
    eventNameLabel.numberOfLines = 0
    styleText(
      label: locationNameLabel,
      text: event.location.fullName,
      size: 18,
      color: .fontLabelInverted,
      style: .medium
    )
  }

  private func setupActionButtons() {
		closeButtonView.setTitle(String.fontMaterialIcon("close"), for: .normal)
		closeButtonView.titleLabel?.font = UIFont.icon(from: .materialIcon, ofSize: 30.0)
		closeButtonView.setTitleColor(.fontLabelInverted, for: .normal)
		
		followButtonView.setTitle(String.fontMaterialIcon("favorite.border"), for: .normal)
		followButtonView.titleLabel?.font = UIFont.icon(from: .materialIcon, ofSize: 30.0)
		followButtonView.setTitleColor(.fontLabelInverted, for: .normal)
  }

  private func loadEventImage(url: String) {
		eventImageView.fromExternalUrl(
			url,
			withResizeTo: imageSize,
			loadOn: loadImageQueue
		)
  }
}

extension EventView: EventDescriptionDelegate {
  func scrollTo(description: DescriptionWithImageUrls) {
    let indexOption = dataSource?.event.description.firstIndex(where: { $0 == description })
    guard let index = indexOption else {
      return
    }
    let descriptionView = descriptionViews[index]
		let scrollTo = descriptionsStackView.convert(descriptionView.frame.origin, to: scrollView).y - 150.0
		scrollView.setContentOffset(CGPoint(
			x: 0,
			y: scrollTo
		), animated: false)
  }
}

extension EventView: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if let isInProgress = dataSource?.isCloseAnimationInProgress, isInProgress {
			scrollView.contentOffset.y = -safeAreaInsets.top
			return
		}
		
		let offsetY = scrollView.contentOffset.y
		let relativeDistance = abs(offsetY / Constants.eventImageHeight)
		let fractionComplete = min(max(0, relativeDistance), 1)
		if animator.fractionComplete == fractionComplete { return }
		if animator.fractionComplete < Constants.actionStackAnimationDelayFactor,
			fractionComplete >= Constants.actionStackAnimationDelayFactor {
			closeButtonView.setTitleColor(.fontLabel, for: .normal)
			if let dataSource = dataSource,
				dataSource.userFollowEventState == .notFollowed {
				followButtonView.setTitleColor(.fontLabel, for: .normal)
			}
		} else if animator.fractionComplete > Constants.actionStackAnimationDelayFactor,
			fractionComplete <= Constants.actionStackAnimationDelayFactor {
			closeButtonView.setTitleColor(.fontLabelInverted, for: .normal)
			if let dataSource = dataSource,
				dataSource.userFollowEventState == .notFollowed {
				followButtonView.setTitleColor(
					dataSource.userFollowEventState.iconColor,
					for: .normal
				)
			}
		}
		animator.fractionComplete = fractionComplete
	}
}

protocol EventNodeDataSource: class {
  var event: Event { get }
	var author: User { get }
	var isInsideContextMenu: Bool { get }
	var isCloseAnimationInProgress: Bool { get }
	var userFollowEventState: EventViewController.FollowEventState { get }
}

protocol EventViewSectionDelegate: class {
	var loadImageQueue: DispatchQueue { get }
	var loadImageSemaphore: DispatchSemaphore { get }
}
