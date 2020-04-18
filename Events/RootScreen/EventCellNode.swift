//
//  EventCellNode.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Promises
import Hero
import SwiftIconFont
import AsyncDisplayKit
import func AVFoundation.AVMakeRect

class EventCellNode: ASCellNode {
  weak var delegate: EventCellNodeDelegate?
  let eventImageNode = ASImageNode()
  private let event: Event
  private let author: User
  private let nameTextNode = ASTextNode()
  private let locationTextNode = ASTextNode()
  private let locationIconImageNode = ASImageNode()
  private let locationBackgroundNode: ASDisplayNode
  private let authorAvatarImageNode = ASImageNode()
  private let authorNameTextNode = ASTextNode()
  private let dateTextNode = ASTextNode()
	private var isEventImageLoaded: Bool = false
  
  struct Constants {
    static let authorImageSize = CGSize(width: 30, height: 30)
    static let cellPaddingHorizontal: CGFloat = 10
    static var eventImageSize: CGSize = CGSize(
			width: UIScreen.main.bounds.width - (Constants.cellPaddingHorizontal * 2.0),
			height: 250.0
		)
  }

  init(event: Event, author: User, reusablePinIcon: UIImage) {
    self.event = event
    self.author = author
    locationBackgroundNode = ASDisplayNode(viewBlock: {
      RoundedView(
        cornerRadii: CGSize(width: 10, height: 10),
        backgroundColor: UIColor.background.withAlphaComponent(0.6)
      )
    })
    super.init()
    automaticallyManagesSubnodes = true

    styleLayerBackedText(
      textNode: nameTextNode,
      text: event.name,
      size: 22,
      color: .fontLabel,
      style: .bold
    )
    locationIconImageNode.tintColor = .highlightBlue
    locationIconImageNode.image = reusablePinIcon
		[eventImageNode, authorAvatarImageNode].forEach { v in
			v.backgroundColor = .skeletonBackground
			v.cornerRadius = 10
			v.cornerRoundingType = .defaultSlowCALayer
		}
    setupLocationSection()
    setupAuthorSection()
    setupDateSection()
  }

  override func didLoad() {
    super.didLoad()
		locationBackgroundNode.backgroundColor = .clear
    eventImageNode.view.hero.id = event.id
  }

  override func layout() {
    super.layout()
    backgroundColor = .background
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    eventImageNode.style.preferredSize = CGSize(
			width: constrainedSize.max.width,
			height: Constants.eventImageSize.height
		)
    let locationStack = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 6,
      justifyContent: .start,
      alignItems: .center,
      children: [locationIconImageNode, locationTextNode]
    )
    let locationWithBgSpec = ASBackgroundLayoutSpec(
      child: ASInsetLayoutSpec(
        insets: UIEdgeInsets(top: 7, left: 7, bottom: 5, right: 12),
        child: locationStack
      ),
      background: locationBackgroundNode
    )
    let eventImageAndLocationOverlaySpec = ASOverlayLayoutSpec(
      child: eventImageNode,
      overlay: ASInsetLayoutSpec(
        insets: UIEdgeInsets(top: CGFloat.infinity, left: 0, bottom: 0, right: CGFloat.infinity),
        child: locationWithBgSpec
      )
    )

    authorAvatarImageNode.style.preferredSize = Constants.authorImageSize
    let authorStack = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 6,
      justifyContent: .start,
      alignItems: .center,
      children: [authorAvatarImageNode, authorNameTextNode]
    )

    locationIconImageNode.style.preferredSize = CGSize(width: 30, height: 30)
    let descriptionVerticalStack = ASStackLayoutSpec.vertical()
    descriptionVerticalStack.spacing = 6
    descriptionVerticalStack.children = [nameTextNode, dateTextNode, authorStack]
    let insetSpec = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10),
      child: descriptionVerticalStack
    )

    let verticalStack = ASStackLayoutSpec.vertical()
    verticalStack.children = [eventImageAndLocationOverlaySpec, insetSpec]
    let contentInsetSpec = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0),
      child: verticalStack
    )
    return contentInsetSpec
  }

  override func didEnterVisibleState() {
    loadMainImage()
		loadAvatarImage()
  }
	
	override func didExitVisibleState() {
		eventImageNode.image = nil
	}

  private func setupLocationSection() {
    styleLayerBackedText(
      textNode: locationTextNode,
      text: event.location.fullName,
      size: 18,
      color: .fontLabel,
      style: .medium
    )
    locationTextNode.maximumNumberOfLines = 1
    locationIconImageNode.contentMode = .center
    locationIconImageNode.isLayerBacked = true
  }

  private func setupAuthorSection() {
    styleLayerBackedText(
      textNode: authorNameTextNode,
      text: author.fullName,
      size: 18,
      color: .fontLabel,
      style: .medium
    )
    authorNameTextNode.maximumNumberOfLines = 1
    authorAvatarImageNode.contentMode = .scaleAspectFill
    authorAvatarImageNode.clipsToBounds = true
  }

  private func setupDateSection() {
    styleLayerBackedText(
      textNode: dateTextNode,
      text: event.dateLabelText,
      size: 18,
      color: .fontLabel,
      style: .medium
    )
  }

  private func setLoadedEventImage(_ image: UIImage) {
		if isEventImageLoaded {
			eventImageNode.image = image
			return
		}
		isEventImageLoaded = true
		eventImageNode.backgroundColor = .background
		eventImageNode.cornerRoundingType = .precomposited
    DispatchQueue.main.async {
			UIView.transition(
				with: self.eventImageNode.view,
				duration: 0.5,
				options: [.curveEaseOut, .transitionCrossDissolve],
				animations: {
					self.eventImageNode.image = image
					self.setNeedsLayout()
				},
				completion: nil
			)
		}
  }
	
	private func setLoadedAvatarImage(_ image: UIImage) {
		authorAvatarImageNode.backgroundColor = .background
		authorAvatarImageNode.cornerRoundingType = .precomposited
		authorAvatarImageNode.image = image
	}

  private func loadMainImage() {
    guard let url = event.mainImageUrl, let delegate = delegate else { return }
    delegate
			.loadImage(RootScreenViewController.LoadImageParams(
				url: url,
				size: Constants.eventImageSize
			))
      .then {[weak self] image in
        self?.setLoadedEventImage(image)
      }
  }
	
	private func loadAvatarImage() {
		guard let url = author.avatar, let delegate = delegate else { return }
		delegate
			.loadImage(RootScreenViewController.LoadImageParams(
				url: url,
				size: Constants.authorImageSize
			))
			.then {[weak self] image in
				self?.setLoadedAvatarImage(image)
			}
	}
}

protocol EventCellNodeDelegate: class {
	var loadImage: (_: RootScreenViewController.LoadImageParams) -> Promise<UIImage> { get }
}
