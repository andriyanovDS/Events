//
//  EventCellView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Promises
import SwiftIconFont
import AsyncDisplayKit
import func AVFoundation.AVMakeRect

class EventCellNode: ASCellNode {
  weak var delegate: EventCellNodeDelegate?
  private let event: Event
  private let author: User
  private let nameTextNode = ASTextNode()
  private let imageBackgroundNode: ASDisplayNode
  private let eventImageNode = ASImageNode()
  private let locationTextNode = ASTextNode()
  private let locationIconImageNode = ASImageNode()
  private let locationBackgroundNode: ASDisplayNode
  private let authorAvatarBackgroundView: ASDisplayNode
  private let authorAvatarImageNode = ASImageNode()
  private let authorNameTextNode = ASTextNode()
  private let dateTextNode = ASTextNode()
  private var imageSize: CGSize {
    let scaleFactor = UIScreen.main.scale
    let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
    return CGSize(width: bounds.width, height: Constants.imageHeight).applying(scale)
  }
  private var eventDateLabelText: String {
    guard let firstDate = event.dates.first else {
      return ""
    }
    let lastDateOption = event.dates.last
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let startTime = dateFormatter.string(from: firstDate)
    let currentYear = Calendar.current.component(.year, from: Date())
    let labelWithOptionYear = {(date: Date) -> String in
      let dateYear = Calendar.current.component(.year, from: date)
      if dateYear == currentYear {
        dateFormatter.dateFormat = "dd.MM"
        return dateFormatter.string(from: date)
      }
      dateFormatter.dateFormat = "dd.MM YYYY"
      return dateFormatter.string(from: date)
    }
    if let lastDate = lastDateOption {
      return [firstDate, lastDate]
        .map { labelWithOptionYear($0) }
        .joined(separator: " - ") + " \(startTime)"
    }
    return "\(labelWithOptionYear(firstDate)) \(startTime)"
  }
  
  struct Constants {
    static let authorImageSize = CGSize(width: 30, height: 30)
    static let cellPaddingHorizontal: CGFloat = 10
    static let imageHeight: CGFloat = 250.0
    static let imageWidth: CGFloat = UIScreen.main.bounds.width - (Constants.cellPaddingHorizontal * 2.0)
  }

  init(event: Event, author: User) {
    self.event = event
    self.author = author
    imageBackgroundNode = ASDisplayNode(viewBlock: {
      RoundedView(cornerRadii: CGSize(width: 10, height: 10), backgroundColor: .gray100())
    })
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
    eventImageNode.contentMode = .scaleAspectFill
    eventImageNode.clipsToBounds = true
    eventImageNode.imageModificationBlock = { image in
      return image.makeRoundedImage(
        size: CGSize(width: Constants.imageWidth, height: Constants.imageHeight),
        radius: 10
      )
    }
    setupLocationSection()
    setupAuthorSection()
    setupDateSection()
  }

  override func layout() {
    super.layout()
    backgroundColor = .white
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let imageSize = CGSize(
       width: constrainedSize.max.width,
       height: Constants.imageHeight
     )
    imageBackgroundNode.style.preferredSize = imageSize
    eventImageNode.style.preferredSize = imageSize
    let overlaySpec = ASOverlayLayoutSpec(child: imageBackgroundNode, overlay: eventImageNode)
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
      child: overlaySpec,
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

  override func didEnterVisibleState() {
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
      text: eventDateLabelText,
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
          duration: 0.4,
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
    let urlOption = event.description
      .first(where: { !$0.imageUrls.isEmpty })
      .chain { $0.imageUrls.first }

    guard let url = urlOption else { return }

    InternalImageCache.shared.loadImage(by: url)
      .then(on: .main) {[weak self] image -> UIImage? in
        guard let self = self else { return nil }
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(
          x: 0, y: 0, width: self.imageSize.width, height: self.imageSize.height
        ))
        let size = CGSize(width: rect.width, height: rect.height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
          image.draw(in: CGRect(origin: .zero, size: size))
        }
      }
    .then {[weak self] image in
      guard let image = image else { return }
      self?.setLoadedEventImage(image)
    }
  }
}

protocol EventCellNodeDelegate: class {
  var loadUserAvatar: (_: String) -> Promise<UIImage> { get }
}
