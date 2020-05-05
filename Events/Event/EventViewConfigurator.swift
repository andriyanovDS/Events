//
//  EventViewConfigurator.swift
//  Events
//
//  Created by Dmitry on 20.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation

class EventViewConfigurator {
  var descriptionCount: Int {
    dataSource.event.description.count
  }
  private let dataSource: EventViewConfiguratorDataSource
  
  init(dataSource: EventViewConfiguratorDataSource) {
    self.dataSource = dataSource
  }
  
  func configureHeaderView(_ view: EventHeaderActionsView) {
    guard let userEvent = dataSource.userEvent else { return }
    view.isFollowButtonActive = userEvent.isFollow
  }
  
  func configureFooterView(_ view: EventFooterView) {
    guard let userEvent = dataSource.userEvent else { return }
    view.joinButtonState = userEvent.isJoin
      ? .joined
      : .notJoined
  }
  
  func configureCardView(_ view: EventCardView) {
    let event = dataSource.event
    view.categoryLabel.text = event.categories
      .map { $0.translatedLabel() }
      .joined(separator: ", ")
    view.titleLabel.text = event.name
    view.locationLabel.text = event.location.fullName
  }
  
  func configureAdditionalInfoView(_ view: EventAdditionalInfoView) {
    let sections = [
      EventInfoSection(
        sectionType: .date(dateTitle: dataSource.event.dateLabelText)
      ),
      EventInfoSection(
        sectionType: .duration(durationRangeTitle: dataSource.event.duration.localizedLabel)
      )
    ]
    view.addSections(sections)
  }
  
  func configureAuthorView(_ view: EventAuthorView) {
    guard let author = dataSource.author else { return }
    view.nameLabel.text = author.fullName
    if let avatar = author.avatar {
      view.avatarImageView.fromExternalUrl(
        avatar,
        withResizeTo: EventAuthorView.Constants.avatarImageSize
      )
    }
  }
  
  func configureLocationView(_ view: EventLocationView) {
    let location = CLLocation(
      latitude: dataSource.event.location.lat,
      longitude: dataSource.event.location.lng
    )
    view.setupMapSnapshot(withPinAt: location)
  }
  
  func configureDescriptionView(_ view: EventDescriptionView, at index: Int) {
    let description = dataSource.event.description[index]
    view.descriptionLabel.text = description.text
    view.titleButton.setTitle(
      description.title ?? NSLocalizedString("What you'll do", comment: "Event description title"),
      for: .normal
    )
    view.startImagesLoading = {[weak view] in
      description.imageUrls
        .enumerated()
        .forEach { (index, image) in
          let size = EventDescriptionView.Constants.imageSize(at: index)
          ExternalImageCache.shared.loadImage(by: image)
            .then(on: .global()) { image in
              let resizedImage = UIImage.resize(image, expectedSize: size)
              guard let image = resizedImage else { return }
              DispatchQueue.main.async {
                view?.addImage(image, withSize: size)
              }
            }
        }
    }
  }
}

protocol EventViewConfiguratorDataSource {
  var event: Event { get }
  var author: User? { get }
  var userEvent: UserEventState? { get }
}
