//
//  EventCellView.swift
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
  private let authorAvatarBackgroundView: ASDisplayNode
  private let authorAvatarImageNode = ASImageNode()
  private let authorNameTextNode = ASTextNode()
  private let dateTextNode = ASTextNode()
  
  struct Constants {
    static let authorImageSize = CGSize(width: 30, height: 30)
    static let cellPaddingHorizontal: CGFloat = 10
    static let imageHeight: CGFloat = 250.0
    static let imageWidth: CGFloat = UIScreen.main.bounds.width - (Constants.cellPaddingHorizontal * 2.0)
    static var eventImageSize: CGSize = {
      let scaleFactor = UIScreen.main.scale
      let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
      return CGSize(
        width: UIScreen.main.bounds.width - Constants.cellPaddingHorizontal * 2,
        height: Constants.imageHeight
      ).applying(scale)
    }()
  }

  init(event: Event, author: User) {
    self.event = event
    self.author = author
    authorAvatarBackgroundView = ASDisplayNode(viewBlock: {
      RoundedView(
        cornerRadii: Constants.authorImageSize.applying(
          CGAffineTransform(scaleX: 0.5, y: 0.5)
        ),
        backgroundColor: .gray100()
      )
    })
    locationBackgroundNode = ASDisplayNode(viewBlock: {
      RoundedView(
        cornerRadii: CGSize(width: 10, height: 10),
        backgroundColor: UIColor.white.withAlphaComponent(0.6)
      )
    })
    super.init()
    automaticallyManagesSubnodes = true

    styleLayerBackedText(
      textNode: nameTextNode,
      text: event.name,
      size: 22,
      color: .black,
      style: .bold
    )
		eventImageNode.backgroundColor = .gray100()
		eventImageNode.cornerRadius = 10
		eventImageNode.cornerRoundingType = .defaultSlowCALayer
    setupLocationSection()
    setupAuthorSection()
    setupDateSection()
  }

  override func didLoad() {
    super.didLoad()
		locationBackgroundNode.backgroundColor = .clear
		authorAvatarBackgroundView.backgroundColor = .clear
    eventImageNode.view.hero.id = event.id
  }

  override func layout() {
    super.layout()
    backgroundColor = .white
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    eventImageNode.style.preferredSize = CGSize(
			width: constrainedSize.max.width,
			height: Constants.imageHeight
		)
    let locationStack = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 6,
      justifyContent: .start,
      alignItems: .center,
      children: [locationIconImageNode, locationTextNode]
    )
    let lockationWithBgSpec = ASBackgroundLayoutSpec(
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
        child: lockationWithBgSpec
      )
    )

    authorAvatarImageNode.style.preferredSize = Constants.authorImageSize
    authorAvatarBackgroundView.style.preferredSize = Constants.authorImageSize
    let authorAvatarOverlaySpec = ASOverlayLayoutSpec(
      child: authorAvatarBackgroundView,
      overlay: authorAvatarImageNode
    )
    let authorStack = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 6,
      justifyContent: .start,
      alignItems: .center,
      children: [authorAvatarOverlaySpec, authorNameTextNode]
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
    let contentIsetSpec = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0),
      child: verticalStack
    )
    return contentIsetSpec
  }

  override func didEnterDisplayState() {
    loadMainImage()
    guard let imageUrl = author.avatar else { return }
    delegate?.loadUserAvatar(imageUrl)
      .then(on: .main) {[weak self] image in
        self?.authorAvatarImageNode.image = image
    }
  }

  private func setupLocationSection() {
    styleLayerBackedText(
      textNode: locationTextNode,
      text: event.location.fullName,
      size: 18,
      color: .black,
      style: .medium
    )
    locationTextNode.maximumNumberOfLines = 1
    locationIconImageNode.image = UIImage(
      from: .materialIcon,
      code: "location.on",
      textColor: .blue(),
      backgroundColor: .clear,
      size: CGSize(width: 30, height: 30)
    )
    locationIconImageNode.isLayerBacked = true
  }

  private func setupAuthorSection() {
    styleLayerBackedText(
      textNode: authorNameTextNode,
      text: author.fullName,
      size: 18,
      color: .black,
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
      color: .black,
      style: .medium
    )
  }

  private func setLoadedEventImage(_ image: UIImage) {
    if isInDisplayState {
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
    } else {
      eventImageNode.image = image
      setNeedsLayout()
    }
  }

  private func loadMainImage() {
    guard let url = event.mainImageUrl, let delegate = delegate else { return }
    delegate
      .loadEventImage(url)
      .then {[weak self] image in
				self?.eventImageNode.backgroundColor = .white
				self?.eventImageNode.cornerRoundingType = .precomposited
        self?.setLoadedEventImage(image)
      }
  }
}

protocol EventCellNodeDelegate: class {
  var loadUserAvatar: (_: String) -> Promise<UIImage> { get }
  var loadEventImage: (_: String) -> Promise<UIImage> { get }
}
